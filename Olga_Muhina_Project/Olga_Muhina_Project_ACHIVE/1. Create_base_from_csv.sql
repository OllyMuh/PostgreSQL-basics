DROP DATABASE IF EXISTS used_vehicles;
CREATE DATABASE used_vehicles;

DROP SCHEMA IF EXISTS uv;
CREATE SCHEMA uv;


DROP TABLE IF EXISTS uv.base;

CREATE TABLE uv.base (
	id bigint,							-- entry ID
	url varchar(255),					-- listing URL
	region varchar(100),				-- craigslist region
	region_url varchar(100),			-- region URL
	price bigint,						-- entry price
	"year" int4,						-- entry year
	manufacturer varchar(50),			-- manufacturer of vehicle
	model varchar(255),					-- model of vehicle
	"condition" varchar(50),			-- condition of vehicle
	cylinders varchar(50),				-- number of cylinders
	fuel varchar(50),					-- fuel type
	odometer int4,						-- miles traveled by vehicle
	title_status varchar(50),			-- title status of vehicle
	transmission varchar(950),			-- transmission of vehicle
	VIN varchar(100),					-- vehicle identification number
	drive varchar(10),					-- type of drive
	"size" varchar(20),					-- size of vehicle
	"type" varchar(20),					-- generic type of vehicle
	paint_color varchar(100),			-- color of vehicle
	image_url varchar(67),				-- image URL
	description text,					-- listed description of vehicle
	county varchar(1),					-- useless column left in by mistake
	state varchar(3),					-- state of listing
	lat float4,							-- latitude of listing
	long float4,						-- longitude of listing
	posting_date varchar(24)			
	
);

COPY 
	uv.base(id, url, region, region_url, price, "year", manufacturer, model, "condition", cylinders, fuel, odometer, title_status, transmission, VIN, drive, "size",
	"type", paint_color, image_url, description, county, state, lat, long, posting_date)
FROM '/home/oem/Cleaning_DATA/vehicles.csv' DELIMITER ',' CSV HEADER;

ALTER TABLE uv.base DROP COLUMN county;
