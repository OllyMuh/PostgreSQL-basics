/*to do this task I needed to delete duplicates which were created in the database when I made id from the .sh file
 * I check the results - they are correct - quantity of rows and sometimes results by amount_sold of current customers*/


/* 1 *
Build the query to generate a report about the most significant customers (which have maximum sales) through various sales channels.
The 5 largest customers are required for each channel.
Column sales_percentage shows percentage of customer’s sales within channel sales
*/

																		
SELECT 	channel_desc, 
		cust_last_name, 
		cust_first_name, 
		amount_sold,
		sales_percentage
FROM 
	(SELECT c2.channel_desc, 										-- channel_desc 
			c.cust_last_name, 										-- cust_last_name
			c.cust_first_name,										-- cust_first_name
			c.cust_id,												-- added TO correct RESULT because OF namesakes
			sum(s.amount_sold) AS amount_sold,						-- amount_sold
			RANK () OVER (PARTITION BY c2.channel_desc ORDER BY sum(s.amount_sold) DESC) AS rank_by_channel,			-- ranks OF customers
			TO_CHAR(100*sum(s.amount_sold)/sum(sum(s.amount_sold)) OVER (PARTITION BY c2.channel_desc), '0.99999'||' %') AS sales_percentage 	-- sales_percentage of the customer ( .11111 %)
	FROM sh.sales s
	JOIN sh.customers c ON c.cust_id = s.cust_id
	JOIN sh.channels c2 ON c2.channel_id = s.channel_id
	GROUP BY c2.channel_desc, c.cust_first_name, c.cust_last_name, c.cust_id) tab
WHERE rank_by_channel <= 5;


/* 2 *
Compose query to retrieve data for report with sales totals for all products in Photo category in Asia (use data for 2000 year). Calculate report total
(YEAR_SUM).
* There are a lot of ways to get such report. You can try to use crosstab function. More information you can find here:
https://www.postgresql.org/docs/12/tablefunc.html
*/
 -- product_name
 -- q1
 -- q2
 -- q3
 -- q4
 -- year_sum

CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT prod_name,
        COALESCE (to_char(q1, '9999999.99'), ' ') AS "q1",
        COALESCE (to_char(q2, '9999999.99'), ' ') AS "q2",
        COALESCE (to_char(q3, '9999999.99'), ' ') AS "q3",
        COALESCE (to_char(q4, '9999999.99'), ' ') AS "q4",
        COALESCE(q1, 0) + COALESCE (q2, 0) + COALESCE (q3, 0) + COALESCE (q4, 0) AS year_sum
FROM crosstab(
    'SELECT p.prod_name,
            t.calendar_quarter_number as q,																-- q1, q2, q3, q4 -- how it adds numbers to q?????
            sum(sum(s.amount_sold)) OVER (PARTITION BY p.prod_name, t.calendar_quarter_number) AS sum_q
    FROM sh.sales s 
	    JOIN sh.products p ON s.prod_id = p.prod_id
	    JOIN sh.times t ON t.time_id = s.time_id
		JOIN sh.customers c on c.cust_id = s.cust_id
		JOIN sh.countries c2 ON c2.country_id = c.country_id
    WHERE t.calendar_year = 2000 AND p.prod_category = ''Photo'' AND c2.country_region = ''Asia''
    GROUP BY p.prod_name, t.calendar_quarter_number
    ORDER BY p.prod_name, t.calendar_quarter_number')
AS query(prod_name varchar(50), q1 NUMERIC, q2 NUMERIC, q3 NUMERIC, q4 NUMERIC);


/* 3 *
Build the query to generate a report about customers who were included into TOP 300 (based on the amount of sales) in 1998, 1999 and 2001. This
report should separate clients by sales channels, and, at the same time, channels should be calculated independently (i.e. only purchases made on
selected channel are relevant).
*/

-- channel_desc
-- cust_id
-- cust_last_name
-- cust_first_name
-- amount_sold

SELECT channel_desc, cust_id, cust_last_name, cust_first_name, 
		to_char(sum(amount_sold), '99 999.99') AS amount_sold
FROM 
	(SELECT c2.channel_desc, 										-- channel_desc 
			c.cust_id,
			c.cust_last_name, 										-- cust_last_name
			c.cust_first_name, 										-- cust_first_name
			t.calendar_year,
			sum(s.amount_sold) AS amount_sold,						
			RANK () OVER (PARTITION BY t.calendar_year, c2.channel_id ORDER BY sum(s.amount_sold) DESC) AS cust_ranks			-- ranking customers BY sales
	FROM sh.sales s
	JOIN sh.customers c USING(cust_id)
	JOIN sh.channels c2 USING(channel_id)
	JOIN sh.times t USING(time_id) 
	WHERE t.calendar_year IN (1998, 1999, 2001)						-- filtering BY calendar_year
	GROUP BY c.cust_id, t.calendar_year, c2.channel_id) tab
WHERE cust_ranks <= 300												-- making top-300
GROUP BY cust_id, channel_desc, cust_last_name, cust_first_name
HAVING count(DISTINCT calendar_year) = 3							-- FOR the customers who were during 3 years IN top-300
ORDER BY sum(amount_sold) desc;																			

/* 4 *
Build the query to generate the report about sales in America and Europe:
Conditions:
• TIMES.CALENDAR_MONTH_DESC: 2000-01, 2000-02, 2000-03
• COUNTRIES.COUNTRY_REGION: Europe, Americas.
*/

-- calendar_month_desc
-- prod_category
-- Americas_SALES
-- Europe_SALES

SELECT	t.calendar_month_desc, 
		p.prod_category,
		round(sum(s.amount_sold) 
				FILTER (WHERE initcap(c2.country_region) = 'Americas'), 0) AS "Americas SALES",
		round(sum(s.amount_sold) 
				FILTER (WHERE initcap(c2.country_region) = 'Europe'), 0) AS "Europe SALES"
FROM sh.sales s
	JOIN sh.products p ON p.prod_id = s.prod_id	
	JOIN sh.customers c ON c.cust_id = s.cust_id
	JOIN sh.countries c2 ON c2.country_id = c.country_id	
	JOIN sh.times t ON t.time_id = s.time_id
WHERE calendar_month_desc IN ('2000-01', '2000-02', '2000-03')
GROUP BY t.calendar_month_desc, p.prod_category 
ORDER BY t.calendar_month_desc;


