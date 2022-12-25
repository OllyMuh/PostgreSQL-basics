/*
Business questions:

1. Describe the correlation of vehicles price on other factors. Find most significant.
2. Find the most selling region to go to
3. Find underestimated vehicles TO make the profitable deal 

*/

/*
 * 1. Calculating correlation koefficient for the manufacturers prices with year and odometer:
 */


-- create view for the average data
CREATE OR REPLACE VIEW avg_data AS								-- I need average DATA FOR the correlations
SELECT 
		vt.manufacturer, 
		round(avg(p.price), 2) AS avg_price,
		round(avg(p.odometer)) AS avg_odometer,
		avg(p."year") AS avg_year
FROM uv.publications p 
	JOIN uv.vehicle_titles vt USING (vt_id)
GROUP BY vt.manufacturer;

-- 1.1 price with odometer (numerical - numerical) --- Pirson coefficient		--- -0.4131681089025605
SELECT 	sum((p.price - avg_data.avg_price) * (p.odometer - avg_data.avg_odometer))/	|/(sum((p.price - avg_data.avg_price)^2)* sum((p.odometer - avg_data.avg_odometer)^2)) AS price_odometer
FROM uv.publications p
	JOIN uv.vehicle_titles vt USING(vt_id)
	JOIN avg_data ON avg_data.manufacturer = vt.manufacturer;

-- 1.2. price with YEAR (numerical - numerical) --- Pirson coefficient ----  0.4752106053941027
SELECT 	sum((p.price - avg_data.avg_price) * (p."year" - avg_data.avg_year))/	|/(sum((p.price - avg_data.avg_price)^2)* sum((p."year"- avg_data.avg_year)^2)) AS price_year
FROM uv.publications p
	JOIN uv.vehicle_titles vt USING(vt_id)
	JOIN avg_data ON avg_data.manufacturer = vt.manufacturer;

-- 1.3. price with year for models of the cars - Spierman coefficient
SELECT 	manufacturer,
		1 - (6*sum(rank_diff^2) / (count(manufacturer)*(count(manufacturer)^2-1))) AS correlation_spierman
FROM
	(SELECT vt.manufacturer,
			p.price,
			RANK() OVER (PARTITION BY vt.manufacturer ORDER BY p.price) AS price_rank, -- ranking models by prices
			RANK() OVER (PARTITION BY vt.manufacturer ORDER BY p."year" desc) AS year_rank,-- ranking models BY YEAR
			RANK() OVER (PARTITION BY vt.manufacturer ORDER BY p.price) - RANK() OVER (PARTITION BY vt.manufacturer ORDER BY p."year" desc) AS rank_diff
	FROM uv.publications p 
	JOIN uv.vehicle_titles vt using(vt_id)
	GROUP BY vt.manufacturer, p.price, p."year") tab
GROUP BY manufacturer
ORDER BY manufacturer;


-- 2. dependence of number selling cars on region. Find the most selling region - where to go
SELECT 
		state,
		region,
		quantity_of_sales
FROM
(SELECT l.state,
		l.region,
		count(p.price) AS quantity_of_sales,
		RANK () OVER (PARTITION BY l.state ORDER BY count(p.price) DESC) AS state_rank
FROM uv.publications p
JOIN uv.locations l ON p.loc_id = l.loc_id
GROUP BY l.region, l.state) tab 
WHERE state_rank <= 3;


-- 3. underestimated vehicles TO make the profitable deal with the production year above 2000 having gas engine, automatic transmission and 4wd drive

SELECT 	url,
		posting_date,
		manufacturer,
		model,
		to_char(price, '99 999.00') AS "price $",
		to_char(round(avg_price_model, 2), '99 999.00') AS "avg_price $",
		to_char(avg_price_model - price, '99 999.99') AS "profit $"
FROM
	(SELECT	p.url,
			p.posting_date,
			vt.manufacturer,
			vt.model,
			p.price,
			avg(p.price) OVER (PARTITION BY vt.model) AS avg_price_model
	FROM uv.publications p
	JOIN uv.vehicle_titles vt USING (vt_id)
	JOIN uv.v_engines ve ON ve.veng_id = p.veng_id
	JOIN uv.vehicle_body vb USING (vb_id)
	JOIN uv.drives d ON d.drive_id = vb.drive_id
	JOIN uv.transmissions t ON t.trm_id = vb.trm_id
	WHERE 	p."year" >= 2000
			AND ve.fuel = 'gas'
			AND d.drive_type = '4wd'
			AND t.trm_type = 'automatic'
	GROUP BY vt.manufacturer, vt.model, p.price, p.url, p.posting_date) tab 
WHERE avg_price_model - price > 0
		AND price > 20000 AND price < 40000
ORDER BY avg_price_model - price desc;
