/*
Part 1: Write SQL queries to retrieve the following data
• All comedy movies released between 2000 and 2004, alphabetical
• Revenue of every rental store for year 2017 (columns: address and address2 – as one column, revenue)
• Top-3 actors by number of movies they took part in (columns: first_name, last_name, number_of_movies, sorted by
number_of_movies in descending order)
• Number of comedy, horror and action movies per year (columns: release_year, number_of_action_movies,
number_of_horror_movies, number_of_comedy_movies), sorted by release year in descending order

Part 2: Solve the following problems with the help of SQL
• Which staff members made the highest revenue for each store and deserve a bonus for 2017 year?
• Which 5 movies were rented more than others and what's expected audience age for those movies?
• Which actors/actresses didn't act for a longer period of time than others?
*/SQL_SELECT_Olga_Muhina_HW.sql


-- 1. All comedy movies released between 2000 and 2004, alphabetical
-- I will select title, release year and genre of the movie

SELECT film.title, film.release_year, c.name AS genre
FROM film
-- deleted brackets 
	INNER JOIN film_category fc								-- we need to go to the table category by this way: film >> film_category >> category 
	ON film.film_id = fc.film_id
		INNER JOIN category c 								-- >> category (here we have the name of category)
		ON c.category_id = fc.category_id
			WHERE UPPER(c.name) = 'COMEDY'
			-- added UPPER
			AND film.release_year BETWEEN 2000 AND 2004 	-- filtering by name of category and release year
			ORDER BY title; 								-- alphabetical sorting of the names

			

-- 2. Revenue of every rental store for year 2017 (columns: address and address2 – as one column, revenue)

SELECT 
CONCAT(a.address, ' ', a.address2) AS address_of_store, 	-- adding in one column address and address2
SUM(p.amount) AS revenue 									-- revenue - sum of all amounts of money from the table payment
FROM address a 											-- in this table we have addresses of stores and store_id
		INNER JOIN store s 									-- we need to go to the table payment by this way: store >> staff >> payment
		ON a.address_id = s.address_id
			INNER JOIN staff s2 							-- >> staff
			ON s2.store_id = s.store_id
				INNER JOIN payment p 												-->> payment (here we have money - column amount)
				ON p.staff_id = s2.staff_id
				WHERE EXTRACT(YEAR FROM p.payment_date) = 2017  					--year in the base is 2017 for all payments
				-- added WHERE instead of HAVING in the end + deleted brackets
GROUP BY CONCAT(a.address, ' ', a.address2), EXTRACT(YEAR FROM p.payment_date);




/*3. Top-3 actors by number of movies they took part in (columns: first_name, last_name, number_of_movies, sorted by
number_of_movies in descending order)*/

SELECT a.first_name , a.last_name, 							-- first name and last name of the actor
COUNT(fa.film_id) AS number_of_movies 						-- counting the number of films from the table film_actor
FROM actor a 												-- here we have first name and last name of the actor
	INNER JOIN film_actor fa 								-- going to the table film_actor 
	ON fa.actor_id = a.actor_id
GROUP BY a.actor_id
-- change group from a.first_name and a.last_name to a.actor_id 
ORDER BY COUNT(fa.film_id) DESC 							-- descending order 
LIMIT 3;													-- taking 3 upper actors



/*
4. Number of comedy, horror and action movies per year (columns: release_year, number_of_action_movies,
number_of_horror_movies, number_of_comedy_movies), sorted by release year in descending order
 */

SELECT f.release_year,																			-- did it like on Q&A session. Understood.
		SUM(CASE WHEN UPPER(c.name) = 'ACTION' THEN 1 ELSE 0 END) AS number_of_action_movies,
		SUM(CASE WHEN UPPER(c.name) = 'HORROR' THEN 1 ELSE 0 END) AS number_of_horror_movies,
		SUM(CASE WHEN UPPER(c.name) = 'COMEDY' THEN 1 ELSE 0 END) AS number_of_comedy_movies
FROM film f 
JOIN film_category fc ON f.film_id = fc.film_id 
JOIN category c ON fc.category_id = c.category_id 
GROUP BY f.release_year
ORDER BY f.release_year DESC;

		
-- 5. Which staff members made the highest revenue for each store and deserve a bonus for 2017 year?
	
/* MY FIRST - WRONG
	/* Here we need to find 2 staff members, because there are 2 stores, I will try to find first name,
 last name and revenue for the year.
 
 I have one lack in my solving of the problem - if we have two staff members having maximum revenue
 from the one store, we will not give a bonus to the staff member of the other store. Need help with it.
 */

SELECT s.store_id, 												-- store_id from the table store
s2.first_name, s2.last_name, 									-- first name and last name of the staff member
SUM(p.amount) AS revenue										-- revenue by the staff member
FROM (((address a 												-- here we have store_id
		INNER JOIN store s 										-- going to the staff members by: address >> store >> staff
		ON a.address_id = s.address_id )
			INNER JOIN staff s2 								-- taking first name and last name of the staff mamber
			ON s2.store_id = s.store_id)
				INNER JOIN payment p							-- >> payment: going the money maked by the staff member and taking the column amount 
				ON p.staff_id = s2.staff_id )
GROUP BY s.store_id, s2.first_name, s2.last_name, EXTRACT(YEAR FROM p.payment_date)
HAVING EXTRACT(YEAR FROM p.payment_date) = 2017					-- filtering by the year
ORDER BY SUM(p.amount) DESC										-- ordering the revenue to have maximum on the top
LIMIT 2;														-- taking 2 best (on the top) staff members
*/

WITH rev_aggr AS 															-- did it like on Q&A session. Understood.
		(SELECT s.store_id,
		s.first_name || ' ' || s.last_name AS staff_full_name,
		SUM(p.amount) AS revenue
		FROM payment p 
		INNER JOIN staff s 
		ON s.staff_id = p.staff_id 
		WHERE EXTRACT (YEAR FROM p.payment_date) = 2017
		GROUP BY s.store_id, staff_full_name),
max_rev_aggr AS
		(SELECT rev_aggr.store_id, MAX(rev_aggr.revenue) AS max_rev_aggr
		FROM rev_aggr
		GROUP BY rev_aggr.store_id)
		
SELECT rev_aggr.store_id, rev_aggr.staff_full_name, rev_aggr.revenue
FROM rev_aggr
INNER JOIN max_rev_aggr
ON rev_aggr.revenue = max_rev_aggr.max_rev_aggr;							-- this was most difficult place for me, but I understood


-- Pavel's variant
WITH rev_aggr AS                                                            
        (SELECT s.store_id,
        s.first_name || ' ' || s.last_name AS staff_full_name,
        SUM(p.amount) AS revenue
        FROM payment p 
        INNER JOIN staff s 
        ON s.staff_id = p.staff_id 
        WHERE EXTRACT (YEAR FROM p.payment_date) = 2017
        GROUP BY s.store_id, staff_full_name

         union ALL											-- added line WITH revenue MORE THEN ANY FROM the store 1 TO break the quiery results

         select 2 as store_id, 'First Last Name', 40439.49 	-- this 'First Last Name' didn't SELECT IN the RESULT quiery, Hanna Rainbow FROM the store 1 selected
        ),
max_rev_aggr AS
        (SELECT rev_aggr.store_id, MAX(rev_aggr.revenue) AS max_rev_aggr
        FROM rev_aggr
        GROUP BY rev_aggr.store_id)							
        -- this IS the place WITH store_id and maximum revenue - isn't it? May be there IS another way TO solve it, but this variant works. 

SELECT rev_aggr.store_id, rev_aggr.staff_full_name, rev_aggr.revenue
FROM rev_aggr
INNER JOIN max_rev_aggr
ON rev_aggr.revenue = max_rev_aggr.max_rev_aggr;			-- and this is the using store_id place in the final quiery (because of max_rev_aggr)

-- another variant for you with group by store_id

WITH rev_aggr AS 														
		(SELECT s.store_id,
		s.first_name || ' ' || s.last_name AS staff_full_name,
		SUM(p.amount) AS revenue
		FROM payment p 
		INNER JOIN staff s 
		ON s.staff_id = p.staff_id 
		WHERE EXTRACT (YEAR FROM p.payment_date) = 2017
		GROUP BY s.store_id, staff_full_name)
		
SELECT rev_aggr.store_id, rev_aggr.staff_full_name, rev_aggr.revenue
FROM rev_aggr
WHERE rev_aggr.revenue IN (SELECT MAX(rev_aggr.revenue)
							FROM rev_aggr
							GROUP BY rev_aggr.store_id)
GROUP BY rev_aggr.store_id, rev_aggr.staff_full_name, rev_aggr.revenue;


-- 6. Which 5 movies were rented more than others and what's expected audience age for those movies?

-- I will add title of the movie, meaning of rating and number of rentals

SELECT 
f.title, 													-- title of the movie
CASE 														-- for the row 'rating' adding it's meaning
WHEN f.rating = 'G' THEN 'без ограничений'
WHEN f.rating = 'PG' THEN 'детям рекомендуется с родителями'
WHEN f.rating = 'PG-13' THEN 'дети до 13 лет обязательно с родителями!'
WHEN f.rating = 'R' THEN 'зрители до 17 лет с родителями'
WHEN f.rating = 'NC-17' THEN 'зрители 17 лет и младше не допускаются'
ELSE 'рейтинга нет'
END,
COUNT(r.rental_id) AS number_of_rentals -- number of rentals
FROM film f 												-- here we have title and rating
		JOIN inventory i 									-- we need rentals of films, which is in the table reltal: film >> inventory >> rental
		ON f.film_id = i.film_id
			JOIN rental r 									-- >> rental (here we have rentals and there dates)
			ON i.inventory_id = r.inventory_id
GROUP BY f.title, f.rating
ORDER BY number_of_rentals DESC 							-- order by number of rentals to find most rented of them on the top
LIMIT 5;													-- taking the upper 5



-- 7. Which actors/actresses didn't act for a longer period of time than others?

/* MY TRY - WRONG
-- I can make a table with needed data (not shure it's ok), but how to calculate the difference between the tuples and to make it a row???

SELECT a.first_name, a.last_name, f.release_year
FROM ((actor a 
	RIGHT JOIN film_actor fa 
	ON a.actor_id = fa.actor_id)
		RIGHT JOIN film f 
		ON fa.film_id = f.film_id )
GROUP BY a.first_name, a.last_name, f.release_year
ORDER BY a.first_name, a.last_name;
*/

WITH actors_release AS 
	(
	    SELECT a.actor_id, a.first_name, a.last_name, f.release_year
	    FROM actor a 
	        JOIN film_actor fa ON fa.actor_id = a.actor_id
	        JOIN film f ON f.film_id = fa.film_id
--	    		WHERE 1 = 1 AND a.actor_id = 1
	),
	
actors_years_no_acting AS
	(SELECT ar.actor_id, 
	ar.first_name, 
	ar.last_name, 
	MAX(diff_btw_films) AS years_no_acting 							-- maximum of no acting years for each actor (note for myself)
	FROM 
		(SELECT ar.actor_id,
				ar.first_name,
				ar.last_name,
				-- I'm really stupid - I can't understand how COALESCE works - please give me where to read about such things
				COALESCE (MIN(ar_2.release_year), 2021) - ar.release_year AS diff_btw_films-- COALSECE in orded to calculate difference between last release and current year
				FROM actors_release ar
				    LEFT JOIN actors_release ar_2
				        ON ar_2.actor_id = ar.actor_id
				       AND ar_2.release_year > ar.release_year 		-- also question how it works 
				GROUP BY ar.actor_id, 
				ar.first_name,
				ar.last_name,
				ar.release_year) AS ar
	GROUP BY ar.actor_id, ar.first_name, ar.last_name)
	
SELECT a.first_name, a.last_name, a.years_no_acting
FROM actors_years_no_acting a
WHERE a.years_no_acting = 
						(SELECT max(years_no_acting)
							FROM actors_years_no_acting);






