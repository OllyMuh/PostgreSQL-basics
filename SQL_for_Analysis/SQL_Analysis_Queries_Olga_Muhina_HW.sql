/*
1. For the 2000 — 2001 years (by years and quaters) what was the sum profit for every sale channel 
*/

-- table with channels, times and profits for every day
WITH profit_by_channels AS
	(SELECT c.channel_desc AS channel
		, (p.unit_price - p.unit_cost)* p.quantity_sold AS profit
		, t.calendar_quarter_number
		, t.calendar_year
	FROM profits p
		JOIN times t ON t.time_id = p.time_id	
		JOIN channels c ON c.channel_id = p.channel_id
	WHERE t.calendar_year IN (2000, 2001)
	GROUP BY c.channel_desc, t.calendar_quarter_number, t.calendar_year, p.unit_price, p.unit_cost, p.quantity_sold)
-- result table divided by sales channels, quarters and years
SELECT 	channel,
		concat (calendar_quarter_number, ' quarter of ', calendar_year),
		sum(profit) AS profit
FROM profit_by_channels pbc
GROUP BY channel, calendar_quarter_number, calendar_year;


/*
2. For 2000 — 2001 years (by years and quarters) — what was the quantity of customers for every subregion of sale.
*/
--CREATE EXTENSION IF NOT EXISTS tablefunc;				-- I tried to "return" my result to the normal view

--DROP TABLE IF EXISTS first_table;
--CREATE TABLE first_table AS 
	SELECT concat (t.calendar_quarter_number, ' quarter of ', t.calendar_year):: text AS quarter_year,
				c2.country_subregion:: text AS region, 
				count(s.cust_id)
--				::text 
				AS total_customers
		FROM sales s 
			JOIN customers c ON c.cust_id = s.cust_id 
			JOIN countries c2 ON c2.country_id = c.country_id
			JOIN times t ON t.time_id = s.time_id
		WHERE t.calendar_year IN (2000, 2001)
		GROUP BY c2.country_subregion, t.calendar_quarter_number, t.calendar_year;
		
--SELECT * FROM crosstab (
--	$$SELECT
--			region, 
--			quarter_year,
--			total_customers
--	FROM first_table
--	ORDER BY 1,2$$)
--AS ct(	
--		region text, 
--		quarter_year TEXT, 
-- 		total text); 					-- worked with errors, I can't find where I do wrong


/*
3. For 2000 and 2001 years — show top 5 worst selling items products with their profits
*/

SELECT prod_name, profit, calendar_year
FROM
	(SELECT p2.prod_name, 
			sum((p.unit_price - p.unit_cost)* p.quantity_sold) AS profit, 
			t.calendar_year,
			rank() OVER (PARTITION BY t.calendar_year ORDER BY sum((p.unit_price - p.unit_cost)* p.quantity_sold)) AS rank_by_year
		FROM profits p 
			JOIN products p2 ON p2.prod_id = p.prod_id
			JOIN times t ON t.time_id = p.time_id 
				WHERE t.calendar_year IN (2000, 2001)
	GROUP BY p2.prod_name, t.calendar_year) tab
WHERE rank_by_year <=5;



