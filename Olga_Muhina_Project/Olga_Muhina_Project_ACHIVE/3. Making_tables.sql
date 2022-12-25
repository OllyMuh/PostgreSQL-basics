/*
 * for questions:
 * 1. Насколько сильно зависит цена автомобиля от его пробега - корреляция
 * 2. Автомобили каких марок наиболее сильно теряют в цене в зависимости от пробега - какие автомобили покупать не стоит?
 * 3. Какие предложения самые выгодные и где?
 * 			Затем нужно отсортировать список разниц цен (со средней) так, чтобы самые недооценённые предложения оказались бы в его верхней части. 
 * 			Это и даст список самых выгодных предложений.
 * 
 * 
 * publications -- will be the snowflake model
 * id
 * vehicle_body (VIN, paint_color, type, transmission, drive) -- (drives, transmissions)
 * vehicle_title (manufacturer_id, model)
 * vehicle_condition (title_status, condition, image_url) -- (statuses)
 * vehicle_engine (cylinders, fuel, odometer)
 * vehicle_location (region, state)
 * year
 * price
 * url
 * description
 * posting_date
 * 
id -            missing 0%
url -           missing 0% +
region -        missing 0% +
price -         missing 0% +		-- has price = 0!!! - must be deleted
year -          missing 0% +
manufacturer -  missing 4% +		-- to delete rows with NULL
model -         missing 1% +		-- to delete rows with NULL
condition -     missing 41% +
cylinders -     missing 42% +
fuel -          missing 1% +		-- to delete rows with null
odometer -      missing 1% +		-- to delete rows with null
title_status -  missing 2%	+		-- to delete rows with null
transmission -  missing 1% +		-- to delete rows with null
VIN -           missing 38% +		-- has duplicates (will be less)
drive -         missing 31% +
type -          missing 22% +
paint_color -   missing 31% +
image_url -     missing 0% +
description -   missing 0% +
state -         missing 0% +
posting_date -  missing 0% +
*/

SELECT count(*) FROM uv.base; 									-- 221045 -- must be IN the RESULT TABLE I hope (may be less because of duplicates)

-- drives table
DROP TABLE IF EXISTS uv.drives CASCADE;
CREATE TABLE uv.drives (
	drive_id SERIAL PRIMARY KEY NOT NULL,
	drive_type varchar(10) UNIQUE
	);

INSERT INTO drives (drive_type)
SELECT DISTINCT drive FROM uv.base
WHERE drive IS NOT NULL
ON CONFLICT DO NOTHING;

-- transmissions table
DROP TABLE IF EXISTS uv.transmissions CASCADE;
CREATE TABLE uv.transmissions (
	trm_id SERIAL PRIMARY KEY NOT NULL,
	trm_type varchar(20) UNIQUE
	);

INSERT INTO uv.transmissions (trm_type)
SELECT DISTINCT transmission FROM uv.base
WHERE transmission IS NOT NULL
ON CONFLICT DO NOTHING;


-- statuses table
DROP TABLE IF EXISTS uv.statuses CASCADE;
CREATE TABLE uv.statuses (
	st_id SERIAL PRIMARY KEY NOT NULL,
	st_type varchar(20) UNIQUE
	);

INSERT INTO uv.statuses (st_type)
SELECT DISTINCT title_status FROM uv.base
WHERE title_status IS NOT NULL
ON CONFLICT DO NOTHING;


-- vehicle_title (manufacturer, model)
DROP TABLE IF EXISTS uv.vehicle_titles CASCADE;
CREATE TABLE uv.vehicle_titles (
	vt_id serial PRIMARY KEY NOT NULL,
	manufacturer varchar(50) NOT null,
	model varchar(255),
	CONSTRAINT mod_unique UNIQUE(manufacturer, model)
);

INSERT INTO uv.vehicle_titles (manufacturer, model)
SELECT 	manufacturer, model
FROM uv.base
ON CONFLICT DO NOTHING;
SELECT count(*) FROM uv.vehicle_titles;  			-- 13 566


-- vehicle_body table (VIN, paint_color, type, transmission, drive) <<-- (drives, transmissions)
DROP TABLE IF EXISTS vehicle_body CASCADE;
CREATE TABLE vehicle_body (
	vb_id SERIAL PRIMARY KEY NOT NULL,
	vin varchar(50) UNIQUE,											-- VIN FOR the car IS ALWAYS  unique
	color varchar(100),
	body_type varchar(20),
	trm_id integer REFERENCES uv.transmissions(trm_id) NOT NULL,
	drive_id integer REFERENCES uv.drives(drive_id)
);

INSERT INTO uv.vehicle_body (vin, color, body_type, trm_id, drive_id)
SELECT 	vin,
		paint_color,
		"type",
		(SELECT trm_id FROM transmissions WHERE trm_type = uv.base.transmission),
		(SELECT drive_id FROM drives WHERE drive_type = uv.base.drive)
FROM uv.base
ON CONFLICT DO NOTHING;
SELECT count(*) FROM uv.vehicle_body; 				-- 96 450


-- vehicle conditions table  (title_status, condition, image_url) <-- (statuses)
DROP TABLE IF EXISTS uv.vehicle_cond CASCADE;
CREATE TABLE uv.vehicle_cond (
	cond_id SERIAL PRIMARY KEY NOT NULL,
	st_id int NOT NULL REFERENCES uv.statuses (st_id),
	"condition" varchar(50),
	image_url varchar(67) UNIQUE									-- one image FOR one car (0% missing in the beginning)
);

INSERT INTO uv.vehicle_cond (st_id, "condition", image_url)
SELECT 
	(SELECT st_id FROM uv.statuses WHERE st_type = uv.base.title_status),
	"condition",
	image_url 
FROM uv.base
ON CONFLICT DO NOTHING;
SELECT count(*) FROM uv.vehicle_cond; 				-- 100 994


-- vehicle_engine table (fuel, odometer)
DROP TABLE IF EXISTS uv.v_engines CASCADE;
CREATE TABLE uv.v_engines (
	veng_id SERIAL NOT NULL PRIMARY KEY,
	cylinders varchar(50),
	fuel varchar(50) NOT NULL,
	CONSTRAINT unique_engine UNIQUE (cylinders, fuel)
);

INSERT INTO uv.v_engines (fuel, cylinders)
SELECT DISTINCT
	fuel, cylinders
FROM uv.base
ON CONFLICT DO NOTHING;
SELECT count(*) FROM v_engines;						-- 73 604


-- vehicle_location table (region, state)
DROP TABLE IF EXISTS uv.locations CASCADE;
CREATE TABLE uv.locations (
	loc_id SERIAL NOT NULL PRIMARY KEY,
	region varchar(100) NOT NULL,
	state varchar(3) NOT NULL,
	CONSTRAINT unique_location UNIQUE (region, state)
);

INSERT INTO uv.locations (region, state)
SELECT DISTINCT region, state FROM uv.base 
ON CONFLICT DO NOTHING;
SELECT count(*) FROM locations;						-- 424


-- creating table for publications
DROP TABLE IF EXISTS publications CASCADE;
CREATE TABLE publications (
	id SERIAL PRIMARY KEY NOT NULL,
	vt_id integer NOT NULL REFERENCES uv.vehicle_titles(vt_id),
	vb_id bigint NOT NULL REFERENCES uv.vehicle_body(vb_id),
	cond_id bigint NOT NULL REFERENCES uv.vehicle_cond(cond_id),
	veng_id int DEFAULT 5,
	odometer int,
	"year" int,
	price bigint,
	url varchar(255) UNIQUE,						-- one PUBLICATION FOR one time
	description TEXT,
	loc_id int NOT NULL REFERENCES uv.locations(loc_id),
	posting_date timestamp,
	FOREIGN KEY (veng_id) REFERENCES uv.v_engines(veng_id)
);

INSERT INTO uv.publications (vt_id, vb_id, cond_id, veng_id, odometer, "year", price, url, description, loc_id, posting_date)
SELECT 
	(SELECT vt_id FROM uv.vehicle_titles WHERE manufacturer = uv.base.manufacturer AND model = uv.base.model),
	(SELECT vb_id FROM uv.vehicle_body WHERE vin = uv.base.vin),
	(SELECT cond_id FROM vehicle_cond WHERE image_url = uv.base.image_url),
	(SELECT veng_id FROM v_engines WHERE fuel = uv.base.fuel AND cylinders = uv.base.cylinders),
	odometer,
	"year",
	price,
	url,
	description,
	(SELECT loc_id FROM locations WHERE region = uv.base.region AND state = uv.base.state),
	(SELECT concat(substring(posting_date FROM 1 FOR 10),' ', substring(posting_date FROM 12 FOR 20))::timestamp)
FROM uv.base
ON CONFLICT DO NOTHING;
SELECT count(*) FROM uv.publications;					-- 221 045 - I have ALL the ROWS FROM my cleaned base table

