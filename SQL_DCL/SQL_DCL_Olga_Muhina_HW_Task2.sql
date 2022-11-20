/*
Implement role-based authentication model for dvd_rental database:
• Create group roles: DB developer, backend tester (read-only), customer (read-only for film and actor)
• Create personalized role for any customer already existing in the dvd_rental database. Role name must be client_{first_name}_{last_name}
(omit curly brackets). Customer's payment and rental history must not be empty.
• Assign proper privileges to each role.
• Verify that all roles are working as intended.
*/
DROP GROUP IF EXISTS DB_developer;				-- check for existance before creation 
CREATE GROUP DB_developer;
ALTER ROLE DB_developer WITH login;				-- TO make possible login WITH this roles

DROP GROUP IF EXISTS backend_tester;			-- check for existance before creation 
CREATE GROUP backend_tester;
ALTER ROLE backend_tester WITH login;	

DROP GROUP IF EXISTS customer;					-- check for existance before creation 
CREATE GROUP customer;
ALTER ROLE customer WITH login;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE postgres FROM PUBLIC;


-- granting the privileges to the group DB_developer to read and write
GRANT CONNECT ON DATABASE postgres TO DB_developer;						-- TO CONNECT the database
GRANT USAGE ON SCHEMA public TO DB_developer;							-- TO use the TABLES IN schema
GRANT CREATE ON SCHEMA public TO DB_developer;							-- TO CREATE NEW objects IN schema
GRANT TRUNCATE, SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO DB_developer;	-- 	TO GRANT ACCESS TO the TABLES
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO DB_developer;			-- added privilege TO EXECUTE functions
GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA public TO DB_developer;			-- TO GRANT permissions TO ALL SEQUENCES + added SELECT ON sequences

--creating user in the group and giving him privileges
CREATE ROLE test_role WITH login;
GRANT DB_developer TO test_role;
--DROP USER test_role;

-- granting the privileges to the group backend_tester to read-only
GRANT CONNECT ON DATABASE postgres TO backend_tester;					-- TO CONNECT the database
GRANT USAGE ON SCHEMA public TO backend_tester;							-- TO use the TABLES IN schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO backend_tester;			-- TO READ TABLES IN schema

--creating user in the group and giving him privileges
CREATE ROLE test_role_read WITH 
							PASSWORD 'user'
							login;
GRANT backend_tester TO test_role_read;

-- granting the privileges to the group customer to read-only tables film and actor
GRANT CONNECT ON DATABASE postgres TO customer;					-- TO CONNECT the database
GRANT USAGE ON SCHEMA public TO customer;						-- TO use the TABLES IN schema
GRANT SELECT ON TABLE film, actor TO customer;					-- TO READ only TABLES film and actor IN SCHEMA

--creating user in the group and giving him privileges
CREATE ROLE test_role_customer WITH 
								PASSWORD 'user'
								login;
GRANT customer TO test_role_customer;



-- making the storage of first_name and last_name of users, who have payment and rental history 
CREATE VIEW user_storage AS
SELECT DISTINCT first_name||'_'||last_name AS full_name
FROM public.customer c
JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON r.customer_id = p.customer_id;				-- LEFT JOIN TO foresee situation WHEN existing rental is not payed (with null value of payment) 

--DROP VIEW user_storage;

SELECT * FROM user_storage LIMIT 1; -- DEANNA_BYRD

--creating personalized role
CREATE ROLE client_DEANNA_BYRD WITH login;
GRANT SELECT ON TABLE payment, rental TO client_DEANNA_BYRD;
--DROP USER client_DEANNA_BYRD;

/*
                                           List of roles
     Role name      |                         Attributes                         |    Member of     
--------------------+------------------------------------------------------------+------------------
 backend_tester     |                                                            | {}
 client_deanna_byrd |                                                            | {}
 customer           |                                                            | {}
 db_developer       |                                                            | {}
 postgres           | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 test_role          |                                                            | {db_developer}
 test_role_customer |                                                            | {customer}
 test_role_read     |                                                            | {backend_tester}

 */

-- tests
SELECT * 
FROM information_schema.table_privileges
WHERE grantee = 'db_developer';
/*
 * postgres	db_developer	postgres	public	film_actor	INSERT	NO	NO
postgres	db_developer	postgres	public	film_actor	SELECT	NO	YES
postgres	db_developer	postgres	public	film_actor	UPDATE	NO	NO
postgres	db_developer	postgres	public	film_actor	DELETE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_02	INSERT	NO	NO
postgres	db_developer	postgres	public	payment_p2017_02	SELECT	NO	YES
postgres	db_developer	postgres	public	payment_p2017_02	UPDATE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_02	DELETE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_06	INSERT	NO	NO
postgres	db_developer	postgres	public	payment_p2017_06	SELECT	NO	YES
postgres	db_developer	postgres	public	payment_p2017_06	UPDATE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_06	DELETE	NO	NO
postgres	db_developer	postgres	public	store	INSERT	NO	NO
postgres	db_developer	postgres	public	store	SELECT	NO	YES
postgres	db_developer	postgres	public	store	UPDATE	NO	NO
postgres	db_developer	postgres	public	store	DELETE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_01	INSERT	NO	NO
postgres	db_developer	postgres	public	payment_p2017_01	SELECT	NO	YES
postgres	db_developer	postgres	public	payment_p2017_01	UPDATE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_01	DELETE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_04	INSERT	NO	NO
postgres	db_developer	postgres	public	payment_p2017_04	SELECT	NO	YES
postgres	db_developer	postgres	public	payment_p2017_04	UPDATE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_04	DELETE	NO	NO
postgres	db_developer	postgres	public	table_to_delete	INSERT	NO	NO
postgres	db_developer	postgres	public	table_to_delete	SELECT	NO	YES
postgres	db_developer	postgres	public	table_to_delete	UPDATE	NO	NO
postgres	db_developer	postgres	public	table_to_delete	DELETE	NO	NO
postgres	db_developer	postgres	public	temp_film	INSERT	NO	NO
postgres	db_developer	postgres	public	temp_film	SELECT	NO	YES
postgres	db_developer	postgres	public	temp_film	UPDATE	NO	NO
postgres	db_developer	postgres	public	temp_film	DELETE	NO	NO
postgres	db_developer	postgres	public	inventory	INSERT	NO	NO
postgres	db_developer	postgres	public	inventory	SELECT	NO	YES
postgres	db_developer	postgres	public	inventory	UPDATE	NO	NO
postgres	db_developer	postgres	public	inventory	DELETE	NO	NO
postgres	db_developer	postgres	public	address	INSERT	NO	NO
postgres	db_developer	postgres	public	address	SELECT	NO	YES
postgres	db_developer	postgres	public	address	UPDATE	NO	NO
postgres	db_developer	postgres	public	address	DELETE	NO	NO
postgres	db_developer	postgres	public	language	INSERT	NO	NO
postgres	db_developer	postgres	public	language	SELECT	NO	YES
postgres	db_developer	postgres	public	language	UPDATE	NO	NO
postgres	db_developer	postgres	public	language	DELETE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_03	INSERT	NO	NO
postgres	db_developer	postgres	public	payment_p2017_03	SELECT	NO	YES
postgres	db_developer	postgres	public	payment_p2017_03	UPDATE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_03	DELETE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_05	INSERT	NO	NO
postgres	db_developer	postgres	public	payment_p2017_05	SELECT	NO	YES
postgres	db_developer	postgres	public	payment_p2017_05	UPDATE	NO	NO
postgres	db_developer	postgres	public	payment_p2017_05	DELETE	NO	NO
postgres	db_developer	postgres	public	rental	INSERT	NO	NO
postgres	db_developer	postgres	public	rental	SELECT	NO	YES
postgres	db_developer	postgres	public	rental	UPDATE	NO	NO
postgres	db_developer	postgres	public	rental	DELETE	NO	NO
postgres	db_developer	postgres	public	staff	INSERT	NO	NO
postgres	db_developer	postgres	public	staff	SELECT	NO	YES
postgres	db_developer	postgres	public	staff	UPDATE	NO	NO
postgres	db_developer	postgres	public	staff	DELETE	NO	NO
postgres	db_developer	postgres	public	city	INSERT	NO	NO
postgres	db_developer	postgres	public	city	SELECT	NO	YES
postgres	db_developer	postgres	public	city	UPDATE	NO	NO
postgres	db_developer	postgres	public	city	DELETE	NO	NO
postgres	db_developer	postgres	public	category	INSERT	NO	NO
postgres	db_developer	postgres	public	category	SELECT	NO	YES
postgres	db_developer	postgres	public	category	UPDATE	NO	NO
postgres	db_developer	postgres	public	category	DELETE	NO	NO
postgres	db_developer	postgres	public	country	INSERT	NO	NO
postgres	db_developer	postgres	public	country	SELECT	NO	YES
postgres	db_developer	postgres	public	country	UPDATE	NO	NO
postgres	db_developer	postgres	public	country	DELETE	NO	NO
postgres	db_developer	postgres	public	customer	INSERT	NO	NO
postgres	db_developer	postgres	public	customer	SELECT	NO	YES
postgres	db_developer	postgres	public	customer	UPDATE	NO	NO
postgres	db_developer	postgres	public	customer	DELETE	NO	NO
postgres	db_developer	postgres	public	film_category	INSERT	NO	NO
postgres	db_developer	postgres	public	film_category	SELECT	NO	YES
postgres	db_developer	postgres	public	film_category	UPDATE	NO	NO
postgres	db_developer	postgres	public	film_category	DELETE	NO	NO
postgres	db_developer	postgres	public	actor_info	INSERT	NO	NO
postgres	db_developer	postgres	public	actor_info	SELECT	NO	YES
postgres	db_developer	postgres	public	actor_info	UPDATE	NO	NO
postgres	db_developer	postgres	public	actor_info	DELETE	NO	NO
postgres	db_developer	postgres	public	customer_list	INSERT	NO	NO
postgres	db_developer	postgres	public	customer_list	SELECT	NO	YES
postgres	db_developer	postgres	public	customer_list	UPDATE	NO	NO
postgres	db_developer	postgres	public	customer_list	DELETE	NO	NO
postgres	db_developer	postgres	public	film_list	INSERT	NO	NO
postgres	db_developer	postgres	public	film_list	SELECT	NO	YES
postgres	db_developer	postgres	public	film_list	UPDATE	NO	NO
postgres	db_developer	postgres	public	film_list	DELETE	NO	NO
postgres	db_developer	postgres	public	nicer_but_slower_film_list	INSERT	NO	NO
postgres	db_developer	postgres	public	nicer_but_slower_film_list	SELECT	NO	YES
postgres	db_developer	postgres	public	nicer_but_slower_film_list	UPDATE	NO	NO
postgres	db_developer	postgres	public	nicer_but_slower_film_list	DELETE	NO	NO
postgres	db_developer	postgres	public	sales_by_film_category	INSERT	NO	NO
postgres	db_developer	postgres	public	sales_by_film_category	SELECT	NO	YES
postgres	db_developer	postgres	public	sales_by_film_category	UPDATE	NO	NO
postgres	db_developer	postgres	public	sales_by_film_category	DELETE	NO	NO
postgres	db_developer	postgres	public	sales_by_store	INSERT	NO	NO
postgres	db_developer	postgres	public	sales_by_store	SELECT	NO	YES
postgres	db_developer	postgres	public	sales_by_store	UPDATE	NO	NO
postgres	db_developer	postgres	public	sales_by_store	DELETE	NO	NO
postgres	db_developer	postgres	public	staff_list	INSERT	NO	NO
postgres	db_developer	postgres	public	staff_list	SELECT	NO	YES
postgres	db_developer	postgres	public	staff_list	UPDATE	NO	NO
postgres	db_developer	postgres	public	staff_list	DELETE	NO	NO
postgres	db_developer	postgres	public	payment	INSERT	NO	NO
postgres	db_developer	postgres	public	payment	SELECT	NO	YES
postgres	db_developer	postgres	public	payment	UPDATE	NO	NO
postgres	db_developer	postgres	public	payment	DELETE	NO	NO
postgres	db_developer	postgres	public	film	INSERT	NO	NO
postgres	db_developer	postgres	public	film	SELECT	NO	YES
postgres	db_developer	postgres	public	film	UPDATE	NO	NO
postgres	db_developer	postgres	public	film	DELETE	NO	NO
postgres	db_developer	postgres	public	actor	INSERT	NO	NO
postgres	db_developer	postgres	public	actor	SELECT	NO	YES
postgres	db_developer	postgres	public	actor	UPDATE	NO	NO
postgres	db_developer	postgres	public	actor	DELETE	NO	NO
 */

SELECT * 
FROM information_schema.table_privileges
WHERE grantee = 'backend_tester';
/*
 * postgres	backend_tester	postgres	public	film_actor	SELECT	NO	YES
postgres	backend_tester	postgres	public	payment_p2017_02	SELECT	NO	YES
postgres	backend_tester	postgres	public	payment_p2017_06	SELECT	NO	YES
postgres	backend_tester	postgres	public	store	SELECT	NO	YES
postgres	backend_tester	postgres	public	payment_p2017_01	SELECT	NO	YES
postgres	backend_tester	postgres	public	payment_p2017_04	SELECT	NO	YES
postgres	backend_tester	postgres	public	table_to_delete	SELECT	NO	YES
postgres	backend_tester	postgres	public	temp_film	SELECT	NO	YES
postgres	backend_tester	postgres	public	inventory	SELECT	NO	YES
postgres	backend_tester	postgres	public	address	SELECT	NO	YES
postgres	backend_tester	postgres	public	language	SELECT	NO	YES
postgres	backend_tester	postgres	public	payment_p2017_03	SELECT	NO	YES
postgres	backend_tester	postgres	public	payment_p2017_05	SELECT	NO	YES
postgres	backend_tester	postgres	public	rental	SELECT	NO	YES
postgres	backend_tester	postgres	public	staff	SELECT	NO	YES
postgres	backend_tester	postgres	public	city	SELECT	NO	YES
postgres	backend_tester	postgres	public	category	SELECT	NO	YES
postgres	backend_tester	postgres	public	country	SELECT	NO	YES
postgres	backend_tester	postgres	public	customer	SELECT	NO	YES
postgres	backend_tester	postgres	public	film_category	SELECT	NO	YES
postgres	backend_tester	postgres	public	actor_info	SELECT	NO	YES
postgres	backend_tester	postgres	public	customer_list	SELECT	NO	YES
postgres	backend_tester	postgres	public	film_list	SELECT	NO	YES
postgres	backend_tester	postgres	public	nicer_but_slower_film_list	SELECT	NO	YES
postgres	backend_tester	postgres	public	sales_by_film_category	SELECT	NO	YES
postgres	backend_tester	postgres	public	sales_by_store	SELECT	NO	YES
postgres	backend_tester	postgres	public	staff_list	SELECT	NO	YES
postgres	backend_tester	postgres	public	payment	SELECT	NO	YES
postgres	backend_tester	postgres	public	film	SELECT	NO	YES
postgres	backend_tester	postgres	public	actor	SELECT	NO	YES
 */

SELECT * 
FROM information_schema.table_privileges
WHERE grantee = 'customer';

/*
 *postgres	customer	postgres	public	film	SELECT	NO	YES
postgres	customer	postgres	public	actor	SELECT	NO	YES
*/ 
