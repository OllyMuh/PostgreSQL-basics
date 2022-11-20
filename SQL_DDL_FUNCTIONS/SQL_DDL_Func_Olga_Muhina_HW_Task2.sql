/*
 2. Create a function that will return a list of films by part of the title in stock (for example, films with the word 'love' in the title).
 • So, the title of films consists of ‘%...%’, and if a film with the title is out of stock, please return a message: a movie with that title was not found
• The function should return the result set in the following view (notice: row_num field is generated counter field (1,2, ..., 100, 101, ...))
*/


CREATE OR REPLACE FUNCTION films_by_title_new (IN part_of_title TEXT)
RETURNS TABLE (	row_num bigint,												-- added WITH the corrections
				film_title TEXT,
				language character(20),
				customer_name TEXT,
				rental_date timestamp)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN query
			SELECT  ROW_NUMBER () over(),									-- added TO make the COLUMN row_num
					f.title, 
					l.name, 
					concat(c.first_name, ' ', c.last_name) AS customer_name, -- FULL name OF the customer
					r.rental_date::timestamp
			FROM film f
				JOIN language l ON f.language_id = l.language_id
				JOIN inventory i ON f.film_id = i.film_id 
				JOIN rental r ON r.inventory_id = i.inventory_id
				JOIN customer c ON c.customer_id = r.customer_id
			WHERE f.title LIKE '%'||upper(part_of_title)||'%'; 				-- agrument OF the FUNCTION
	IF NOT FOUND THEN
		RAISE EXCEPTION  'a movie with that title was not found';			-- added raising exception
	END IF;
	RETURN;
END;
$$;

--My tests))
SELECT * FROM films_by_title_new('muho');
