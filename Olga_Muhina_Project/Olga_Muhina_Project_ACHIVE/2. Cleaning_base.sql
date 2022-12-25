/*
 * Cleaning the base to make in useful


Result of the NumPy work:

id -            missing 0%
url -           missing 0%
region -        missing 0%
region_url -    missing 0%			-- not informative - to drop
price -         missing 0%			-- has price = 0!!! - must be deleted
year -          missing 0%
manufacturer -  missing 4%			-- to delete rows with NULL
model -         missing 1%			-- to delete rows with NULL
condition -     missing 41%
cylinders -     missing 42%
fuel -          missing 1%			-- to delete rows with null
odometer -      missing 1%			-- to delete rows with null
title_status -  missing 2%			-- to delete rows with null
transmission -  missing 1%			-- to delete rows with null
VIN -           missing 38%			-- to delete rows with null value
drive -         missing 31%
size -          missing 72%			-- to drop column (a few data)
type -          missing 22%
paint_color -   missing 31%
image_url -     missing 0%
description -   missing 0%
county -        missing 100%		-- to drop column (missing data at all)
state -         missing 0%
lat -           missing 2%			-- useless column - to drop
long -          missing 2%			-- useless column - to drop
posting_date -  missing 0%

 */

ALTER TABLE uv.base DROP COLUMN county;
ALTER TABLE uv.base DROP COLUMN "size";
ALTER TABLE uv.base DROP COLUMN region_url;
ALTER TABLE uv.base DROP COLUMN lat;
ALTER TABLE uv.base DROP COLUMN long;

-- deleting rows where price of the car = 0
SELECT count(*) 
FROM uv.base
WHERE price = 0;

DELETE 
FROM uv.base
WHERE price < 500;

-- deleting rows where there are not model or manufacturer
SELECT count(*)
--manufacturer, 
--model
FROM uv.base
WHERE manufacturer IS NULL OR model IS NULL;

DELETE
FROM uv.base
WHERE manufacturer IS NULL OR model IS NULL;

-- deleting rows where VIN is NULL -- I need to create unique values for the cars

DELETE FROM uv.base 
WHERE vin IS NULL;

-- deleting rows with other NULL attributes 
SELECT count(*)
FROM uv.base
WHERE 	fuel IS NULL OR
		odometer IS NULL OR
		title_status IS NULL OR
		transmission IS NULL OR
		lat IS NULL OR 
		long IS NULL;			-- 15449
		
DELETE
FROM uv.base
WHERE 	fuel IS NULL OR
		odometer IS NULL OR
		title_status IS NULL OR
		transmission IS NULL OR
		lat IS NULL OR 
		long IS NULL;

-- looking for outliers	of the price
	
SELECT DISTINCT price
FROM uv.base
ORDER BY price DESC
;

-- here we have prices more the 1 000 000 000

DELETE
FROM uv.base WHERE price > 1000000000;

-- and prices more the 1 000 000

DELETE
FROM uv.base WHERE price >= 1000000;
		
SELECT * FROM uv.base WHERE price BETWEEN 900000 AND 1000000;		-- 5 cars


-- selecting inapplicable values of important attributes
	
SELECT DISTINCT state FROM uv.base;

DELETE FROM uv.base b 
WHERE title_status = 'missing';

SELECT * FROM uv.base b 



-- searching duplicates will be made during inserting data into the tables

-- creating datetime field from posting_date

-- my tests to make it when insert

SELECT concat(substring(posting_date FROM 1 FOR 10),' ', substring(posting_date FROM 12 FOR 20))::timestamp
FROM uv.base b
WHERE id = '7314300303';



	

