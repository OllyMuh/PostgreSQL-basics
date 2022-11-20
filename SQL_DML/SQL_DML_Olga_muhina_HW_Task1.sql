
/*
 * Choose your top-3 favorite movies and add them to 'film' table. Fill rental rates with 4.99, 9.99 and 19.99 and rental durations with 1, 2 and 3
weeks respectively.
 */
DROP TABLE IF EXISTS temp_film;
CREATE TABLE temp_film (
    film_id integer DEFAULT nextval('film_film_id_seq'::regclass) NOT NULL,
    title text NOT NULL,
    description text,
    release_year year,
    language_id smallint NOT NULL,
    original_language_id smallint,
    rental_duration smallint DEFAULT 3 NOT NULL,
    rental_rate numeric(4,2) DEFAULT 4.99 NOT NULL,
    length smallint,
    replacement_cost numeric(5,2) DEFAULT 19.99 NOT NULL,
    rating mpaa_rating DEFAULT 'G'::mpaa_rating,
    last_update timestamp with time zone DEFAULT now() NOT NULL,
    special_features text[],
    fulltext tsvector NOT NULL
);


INSERT INTO temp_film 
VALUES
(DEFAULT, 'Alice in Wonderland', 'American dark fantasy film directed by Tim Burton from a screenplay written by Linda Woolverton', 2010, 1, 
NULL, 1, 4.99, 108, 14.99, 'G', DEFAULT, '{}', '''beauti'':4  ''wake'':1'),
(DEFAULT, 'Charlie and the Chocolate Factory', 'The storyline follows Charlie as he wins a contest along with four other children and is led by Wonka 
on a tour of his chocolate factory', 2005, 1, NULL, 2, 9.99, 115, 19.99, 'G', DEFAULT, '{}', '''beauti'':4  ''wake'':1'),
(DEFAULT, 'Big Fish', 'The film tells the story of a frustrated son who tries to distinguish fact from fiction in his dying fathers life', 2003, 1,
NULL, 3, 19.99, 125, 29.99, 'PG-13', DEFAULT, '{}', '''beauti'':4  ''wake'':1')
RETURNING title, film_id;

INSERT INTO film (title, description, release_year, language_id, original_language_id, 
rental_duration, rental_rate, replacement_cost, rating, special_features, fulltext)
SELECT title, description, release_year, language_id, original_language_id, 
rental_duration, rental_rate, replacement_cost, rating, special_features, fulltext
FROM temp_film tf
WHERE
NOT EXISTS (SELECT title
			FROM film f
			WHERE f.title = tf.title AND f.description = tf.description);


/*
 * film_ids:
 * Alice in Wonderland - 1001
 * Charlie and the Chocolate Factory - 1002
 * Big Fish - 1003
 */

--SELECT * FROM film f 
--WHERE film_id IN (1001, 1002, 1003);

UPDATE film
SET rental_duration = rental_duration * 7
WHERE date(last_update) = '2021-12-05'; 								-- done - weeks became days

/*
 * Add actors who play leading roles in your favorite movies to 'actor' and 'film_actor' tables (6 or more actors in total).
 */
INSERT INTO actor (first_name, last_name)
VALUES
('Johny', 'Depp'),
('Anne', 'Hattaway'),
('Freddie', 'Highmore'),
('David', 'Kelly'),
('Ewan', 'McGregor'),
('Albert', 'Finney')
RETURNING first_name, last_name, actor_id;

/*
 * actor_ids:
 * Johny Depp - 201
 * Anne Hataway - 202
 * Freddie Highmore - 203 
 * David Kelly - 204
 * Ewan McGregor - 205
 * Albert Finney - 206
 */

--SELECT * FROM actor
--WHERE actor_id IN (201, 202, 203, 204, 205, 206);

INSERT INTO film_actor (film_id, actor_id)
VALUES
(1001, 201),
(1001, 202),
(1002, 203),
(1002, 204),
(1003, 205),
(1003, 206)
RETURNING *;

/*
 * Add your favorite movies to any store's inventory.
 */

INSERT INTO inventory (film_id, store_id)
VALUES
(1001, 1),
(1002, 1),
(1003, 1)
RETURNING *;

/*
 * inventory_ids:
 * 1001 - 4582
 * 1002 - 4583
 * 1003 - 4584
 */

/*
 * Alter any existing customer in the database who has at least 43 rental and 43 payment records. Change his/her personal data to yours (first name,
last name, address, etc.). Do not perform any updates on 'address' table, as it can impact multiple records with the same address. Change
customer's create_date value to current_date.
 */

/*to deside what customer to be I will select all the customers who has at least 43 rental and 43 payment records
 * and store number 1, because I added inventory to this store
 */

-- I will be the customer with customer_id numbered by select statement

UPDATE customer
SET 
first_name = 'OLGA',
last_name = 'MUHINA',
email = 'sajah@mail.ru',
address_id = (
				SELECT address_id 
				FROM address a
				WHERE a.address LIKE '%Wroclaw D%'
				),
create_date = current_date,
last_update = now()
WHERE customer_id = (
					SELECT c.customer_id
					FROM customer c 
					JOIN rental r ON c.customer_id = r.customer_id
					JOIN payment p ON r.rental_id = p.rental_id 
					WHERE c.store_id = 1									-- moved FILTER BY store_id TO the WHERE section
					GROUP BY c.customer_id
					HAVING COUNT(*) >= 43 AND COUNT(p.amount) >= 43
					LIMIT 1);

/*
Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'
*/
SELECT *
FROM customer 
WHERE first_name = 'OLGA' AND last_name = 'MUHINA' AND create_date = '2021-12-09'; 	-- corrected SEARCH -- added last_name
				
SELECT *
FROM rental
WHERE customer_id = 
					(SELECT customer_id 
					FROM customer 
					WHERE first_name = 'OLGA' AND last_name = 'MUHINA' AND create_date = '2021-12-09'); -- 48 ROWS


--first - child table
DELETE FROM payment
WHERE customer_id = 
					(SELECT customer_id 
					FROM customer 
					WHERE first_name = 'OLGA' AND last_name = 'MUHINA' AND create_date = '2021-12-09')
RETURNING *;

--second - parent table
DELETE FROM rental
WHERE customer_id = 
					(SELECT customer_id 
					FROM customer 
					WHERE first_name = 'OLGA' AND create_date = '2021-12-09')
RETURNING *;


/*
Rent you favorite movies from the store they are in and pay for them (add corresponding records to the database to represent this activity)
*/

INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id) 
VALUES
(now(), 
(SELECT inventory_id FROM inventory WHERE film_id = (SELECT film_id FROM film WHERE title LIKE 'Alice%')),
(SELECT customer_id FROM customer WHERE first_name = 'OLGA' AND create_date = '2021-12-09'), 
1),
(now(), 
(SELECT inventory_id FROM inventory WHERE film_id = (SELECT film_id FROM film WHERE title LIKE 'Charlie%')),
(SELECT customer_id FROM customer WHERE first_name = 'OLGA' AND create_date = '2021-12-09'), 
1),
(now(), 
(SELECT inventory_id FROM inventory WHERE film_id = (SELECT film_id FROM film WHERE title LIKE 'Big Fish')),
(SELECT customer_id FROM customer WHERE first_name = 'OLGA' AND create_date = '2021-12-09'), 
1)
RETURNING *;

/*
 * rental_ids:
 * 4582 - 32299
 * 4583 - 32300
 * 4584 - 32301
 */

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES (
		(SELECT customer_id FROM customer WHERE first_name = 'OLGA' AND create_date = '2021-12-09'),  	-- selecting myself
		1,																								-- staff_id 
		(SELECT rental_id FROM rental r
							INNER JOIN inventory i ON r.inventory_id = i.inventory_id
							INNER JOIN film f ON f.film_id = i.film_id 
							WHERE f.title LIKE 'Alice%' AND date(r.rental_date) = '2021-12-09'),		-- selecting rental_id to pay by the film and date
		(SELECT rental_rate FROM film WHERE title LIKE 'Alice%'),										-- selecting rental rate for this film
		now() - INTERVAL '4.5 YEAR'																		-- date of payment in 2017 year
		),
		(
		(SELECT customer_id FROM customer WHERE first_name = 'OLGA' AND create_date = '2021-12-09'),
		1,
		(SELECT rental_id FROM rental r
							INNER JOIN inventory i ON r.inventory_id = i.inventory_id
							INNER JOIN film f ON f.film_id = i.film_id 
							WHERE f.title LIKE 'Charlie%' AND date(r.rental_date) = '2021-12-09'),
		(SELECT rental_rate FROM film WHERE title LIKE 'Charlie%'),
		now() - INTERVAL '4.5 YEAR'
		),
		(
		(SELECT customer_id FROM customer WHERE first_name = 'OLGA' AND create_date = '2021-12-09'),
		1,
		(SELECT rental_id FROM rental r
							INNER JOIN inventory i ON r.inventory_id = i.inventory_id
							INNER JOIN film f ON f.film_id = i.film_id 
							WHERE f.title LIKE 'Big Fish' AND date(r.rental_date) = '2021-12-09'),
		(SELECT rental_rate FROM film WHERE title LIKE 'Big Fish'),
		now() - INTERVAL '4.5 YEAR'
		)
	RETURNING *;							
