/*
1. Create a function that will return the most popular film for each country (where country is an input paramenter).
*/

CREATE OR REPLACE FUNCTION get_most_popular_film (IN country_name TEXT[])		-- corrected TO use ARRAY
RETURNS TABLE (	country TEXT,
				title TEXT,
				rating mpaa_rating,									-- added required fields WITH the 1st corrections
				film_language bpchar,
				film_length smallint,
				release_year YEAR)
AS $$
WITH country_rentals AS												-- making table WITH ALL rentals OF the films IN selected countries
	(SELECT c3.country,
		    c3.country_id,
		    f.film_id, 
		    f.title,
		    f.rating,
		    l.name,
		    f.length, 
		    f.release_year,
		    count(r.rental_id) AS rental_count,
		    sum(p.amount) AS payments												
		FROM film f
			JOIN language l ON f.language_id = l.language_id 
			JOIN inventory i ON f.film_id = i.film_id 
			JOIN rental r ON r.inventory_id = i.inventory_id
			JOIN payment p ON r.rental_id = p.rental_id
			JOIN customer c ON c.customer_id = p.customer_id 
			JOIN address a ON a.address_id = c.address_id 
			JOIN city c2 ON c2.city_id = a.city_id
			JOIN country c3 ON c3.country_id = c2.country_id 
		WHERE c3.country = ANY (country_name)										-- USING arguments OF array, but I can't implement USING initcap()-- need help OR hint
		GROUP BY c3.country, c3.country_id, f.film_id, f.title, f.rating, l.name, f.length, f.release_year)
		
-- selecting most popular films by number of rentals
SELECT country, title, rating, "name", length, release_year
	FROM country_rentals AS rt
	GROUP BY country, title, rating, name, length, release_year, rental_count, country_id, payments
	HAVING rental_count = (SELECT max(rental_count) FROM country_rentals
								WHERE country_rentals.country_id = rt.country_id)
--			AND payments = (SELECT max(payments) FROM country_rentals
--								WHERE country_rentals.country_id = rt.country_id)		-- I tried to filter by payments, but if I do this, I lose duplicates and one country (Brasil)
							;
$$ LANGUAGE sql;

SELECT * FROM get_most_popular_film(array['Canada','Brazil','United States']);

