/*
Read about row-level security (https://www.postgresql.org/docs/12/ddl-rowsecurity.html) and configure it for your database, so that the
customer can only access his own data in "rental" and "payment" tables (verify using the personalized role you previously created).
*/

--enabling row level sequrity to the tables rental and payment
ALTER TABLE public.rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA public TO client_deanna_byrd;					-- TO prevent risks
GRANT SELECT ON TABLE public.payment, public.rental, public.customer TO client_deanna_byrd;		-- TO prevent risks
GRANT customer TO client_deanna_byrd;			-- granting ALL PRIVILEGES OF customer TO client

--for the tests
SET ROLE client_deanna_byrd;
SET ROLE postgres;
--SELECT current_user;

DROP POLICY IF EXISTS rental_customers ON public.rental;
CREATE POLICY rental_customers ON public.rental TO customer
			USING (customer_id = (SELECT customer_id FROM customer 
									WHERE upper(first_name) = upper(split_part(current_user, '_', 2)) AND upper(last_name) = upper(split_part(current_user, '_', 3))));

DROP POLICY IF EXISTS payment_customers ON public.payment;								
CREATE POLICY payment_customers ON public.payment TO customer
			USING (customer_id = (SELECT customer_id FROM customer 
									WHERE upper(first_name) = upper(split_part(current_user, '_', 2)) AND upper(last_name) = upper(split_part(current_user, '_', 3))));

DROP POLICY IF EXISTS customer_use ON public.customer;				-- it doesn't need - POLICies FOR rental AND payment ARE working WITHOUT it, but let it be)
CREATE POLICY customer_use ON public.customer TO customer
			USING (customer_id = (SELECT customer_id FROM customer 
									WHERE upper(first_name) = upper(split_part(current_user, '_', 2)) AND upper(last_name) = upper(split_part(current_user, '_', 3))));
								
SELECT * FROM rental;	-- 52 rows		
SELECT * FROM payment;  --52 rows
/*
rental_id	rental_date		inventory_id	customer_id	return_date			staff_id		last_update
12	2005-05-25 00:19:27.000 +0400	1584	261	2005-05-30 05:44:27.000 +0400	2	2017-02-16 02:30:53.000 +0300
465	2005-05-27 20:44:36.000 +0400	20	261	2005-06-02 02:43:36.000 +0400	1	2017-02-16 02:30:53.000 +0300
542	2005-05-28 06:42:13.000 +0400	4444	261	2005-06-03 09:05:13.000 +0400	1	2017-02-16 02:30:53.000 +0300
792	2005-05-29 16:32:10.000 +0400	2841	261	2005-05-31 18:01:10.000 +0400	1	2017-02-16 02:30:53.000 +0300
1760	2005-06-16 17:48:37.000 +0400	3929	261	2005-06-18 16:01:37.000 +0400	2	2017-02-16 02:30:53.000 +0300
1877	2005-06-17 02:54:16.000 +0400	3404	261	2005-06-25 21:51:16.000 +0400	2	2017-02-16 02:30:53.000 +0300
1988	2005-06-17 10:42:34.000 +0400	3054	261	2005-06-25 11:47:34.000 +0400	2	2017-02-16 02:30:53.000 +0300
2072	2005-06-17 16:33:32.000 +0400	86	261	2005-06-23 13:22:32.000 +0400	1	2017-02-16 02:30:53.000 +0300
2392	2005-06-18 15:34:18.000 +0400	2213	261	2005-06-19 16:22:18.000 +0400	1	2017-02-16 02:30:53.000 +0300
3363	2005-06-21 12:25:07.000 +0400	538	261	2005-06-27 11:52:07.000 +0400	2	2017-02-16 02:30:53.000 +0300
5122	2005-07-09 07:19:35.000 +0400	1423	261	2005-07-16 03:04:35.000 +0400	2	2017-02-16 02:30:53.000 +0300
5449	2005-07-09 22:12:01.000 +0400	921	261	2005-07-18 01:18:01.000 +0400	2	2017-02-16 02:30:53.000 +0300
6515	2005-07-12 03:50:32.000 +0400	706	261	2005-07-15 03:54:32.000 +0400	2	2017-02-16 02:30:53.000 +0300
6743	2005-07-12 14:29:25.000 +0400	158	261	2005-07-13 13:13:25.000 +0400	1	2017-02-16 02:30:53.000 +0300
9552	2005-07-31 02:05:32.000 +0400	3544	261	2005-08-01 06:59:32.000 +0400	1	2017-02-16 02:30:53.000 +0300
9842	2005-07-31 12:24:58.000 +0400	2896	261	2005-08-02 11:01:58.000 +0400	2	2017-02-16 02:30:53.000 +0300
9869	2005-07-31 13:21:54.000 +0400	783	261	2005-08-07 09:09:54.000 +0400	1	2017-02-16 02:30:53.000 +0300
10246	2005-08-01 02:29:50.000 +0400	3598	261	2005-08-09 01:17:50.000 +0400	2	2017-02-16 02:30:53.000 +0300
11834	2005-08-17 13:00:40.000 +0400	2407	261	2005-08-22 12:50:40.000 +0400	1	2017-02-16 02:30:53.000 +0300
11928	2005-08-17 16:28:24.000 +0400	79	261	2005-08-23 17:50:24.000 +0400	2	2017-02-16 02:30:53.000 +0300
12327	2005-08-18 06:43:22.000 +0400	2425	261	2005-08-25 10:50:22.000 +0400	2	2017-02-16 02:30:53.000 +0300
13245	2005-08-19 16:43:41.000 +0400	1001	261	2005-08-20 21:17:41.000 +0400	1	2017-02-16 02:30:53.000 +0300
13506	2005-08-20 02:07:06.000 +0400	1334	261	2005-08-26 08:06:06.000 +0400	1	2017-02-16 02:30:53.000 +0300
13669	2005-08-20 08:26:32.000 +0400	4504	261	2005-08-27 08:10:32.000 +0400	2	2017-02-16 02:30:53.000 +0300
13849	2005-08-20 14:42:34.000 +0400	3774	261	2005-08-24 13:09:34.000 +0400	2	2017-02-16 02:30:53.000 +0300
15397	2005-08-22 23:08:46.000 +0400	1482	261	2005-08-25 20:58:46.000 +0400	1	2017-02-16 02:30:53.000 +0300
16261	2005-05-25 00:09:59.978 +0400	1584	261	2005-06-23 01:51:32.477 +0400	5	2020-02-20 14:39:13.654 +0300
16713	2005-05-27 20:15:15.527 +0400	20	261	2005-06-23 00:54:53.816 +0400	4	2020-02-20 14:39:13.654 +0300
16790	2005-05-28 06:36:35.079 +0400	4444	261	2005-07-02 22:29:06.716 +0400	3	2020-02-20 14:39:13.654 +0300
17040	2005-05-29 16:04:15.027 +0400	2841	261	2005-06-29 19:01:23.217 +0400	4	2020-02-20 14:39:13.654 +0300
18008	2005-06-16 18:09:46.701 +0400	3929	261	2005-06-24 10:28:06.185 +0400	5	2020-02-20 14:39:13.654 +0300
18125	2005-06-17 02:42:18.086 +0400	3404	261	2005-07-24 09:34:25.471 +0400	5	2020-02-20 14:39:13.654 +0300
18236	2005-06-17 10:59:52.297 +0400	3054	261	2005-07-07 04:04:30.191 +0400	5	2020-02-20 14:39:13.654 +0300
18320	2005-06-17 17:01:06.316 +0400	86	261	2005-06-27 17:36:25.541 +0400	4	2020-02-20 14:39:13.654 +0300
18639	2005-06-18 15:57:12.404 +0400	2213	261	2005-07-14 19:32:05.999 +0400	4	2020-02-20 14:39:13.654 +0300
19610	2005-06-21 11:59:42.764 +0400	538	261	2005-07-18 09:06:43.778 +0400	5	2020-02-20 14:39:13.654 +0300
21369	2005-07-09 07:34:29.799 +0400	1423	261	2005-08-05 21:09:33.050 +0400	5	2020-02-20 14:39:13.654 +0300
21696	2005-07-09 22:41:01.279 +0400	921	261	2005-07-24 15:28:16.087 +0400	5	2020-02-20 14:39:13.654 +0300
22762	2005-07-12 03:57:40.051 +0400	706	261	2005-07-19 11:25:35.017 +0400	5	2020-02-20 14:39:13.654 +0300
22989	2005-07-12 14:02:05.328 +0400	158	261	2005-07-14 13:26:01.116 +0400	3	2020-02-20 14:39:13.654 +0300
25797	2005-07-31 02:04:33.914 +0400	3544	261	2005-08-01 08:18:31.792 +0400	4	2020-02-20 14:39:13.654 +0300
26087	2005-07-31 12:51:05.993 +0400	2896	261	2005-08-06 21:07:30.202 +0400	5	2020-02-20 14:39:13.654 +0300
26114	2005-07-31 13:15:15.622 +0400	783	261	2005-08-27 13:00:39.833 +0400	3	2020-02-20 14:39:13.654 +0300
26491	2005-08-01 02:40:55.229 +0400	3598	261	2005-08-14 19:32:05.103 +0400	5	2020-02-20 14:39:13.654 +0300
28081	2005-08-17 13:13:05.747 +0400	2407	261	2005-08-29 10:41:03.302 +0400	3	2020-02-20 14:39:13.654 +0300
28175	2005-08-17 16:11:31.516 +0400	79	261	2005-09-15 02:33:58.455 +0400	5	2020-02-20 14:39:13.654 +0300
28573	2005-08-18 06:17:36.803 +0400	2425	261	2005-09-03 19:53:45.620 +0400	5	2020-02-20 14:39:13.654 +0300
29491	2005-08-19 16:42:15.080 +0400	1001	261	2005-09-02 20:24:47.796 +0400	3	2020-02-20 14:39:13.654 +0300
29752	2005-08-20 02:11:56.880 +0400	1334	261	2005-09-05 14:29:54.585 +0400	3	2020-02-20 14:39:13.654 +0300
29915	2005-08-20 08:23:59.892 +0400	4504	261	2005-08-31 14:10:19.704 +0400	5	2020-02-20 14:39:13.654 +0300
30094	2005-08-20 15:08:14.264 +0400	3774	261	2005-09-15 04:30:07.217 +0400	5	2020-02-20 14:39:13.654 +0300
31642	2005-08-22 23:11:05.241 +0400	1482	261	2005-08-29 20:31:42.880 +0400	3	2020-02-20 14:39:13.654 +0300

 */
									