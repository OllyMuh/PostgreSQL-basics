/*3.Create function that inserts new movie with the given name in ‘film’ table. ‘release_year’, ‘language’ are optional arguments and default to current year and
Russian respectively. The function must return film_id of the inserted movie.
*/

CREATE OR REPLACE FUNCTION add_mowie (IN 	i_new_film_title TEXT,
									i_release_year YEAR = EXTRACT (YEAR FROM current_date), -- ALWAYS CURRENT YEAR (added with the corrections)
									i_language char DEFAULT 'Russian')  -- corrected
RETURNS INTEGER
LANGUAGE plpgsql

AS $$
DECLARE 
		f_id INTEGER;						-- variable FOR RETURNING film_id
		f_language_id INTEGER := NULL; 		-- variable FOR language_id
BEGIN 
	SELECT language_id INTO f_language_id
	FROM public."language" l 
	WHERE l."name" = i_language;
-- if language does not exist
	IF f_language_id IS NULL
	THEN 
		INSERT INTO "language"(name)
		VALUES (i_language)
		RETURNING language_id INTO f_language_id;
	END IF;
-- inserting new movie
	INSERT INTO film (title, release_year, language_id)
	SELECT 
		i_new_film_title AS title,
		i_release_year AS release_year,
		f_language_id AS language_id
	WHERE NOT EXISTS 
		(SELECT * FROM public.film f WHERE f.title = i_new_film_title AND f.release_year = i_release_year)
	RETURNING film_id INTO f_id;
-- to return result -1 if film already in the base
	RETURN COALESCE (f_id, -1);
END;
$$;


-- My tests)))
--SELECT add_mowie ('New movie');
----
--SELECT * FROM film 
--WHERE title = 'New movie';
--
--SELECT * FROM "language";


