-- 1. Figure out what security precautions are already used in your 'dvd_rental' database; -- send description


SELECT rolname FROM pg_catalog.pg_roles;

/*
a role-based privilege model is implemented in the database. 
There are predefined roles:
pg_monitor
pg_read_all_settings
pg_read_all_stats
pg_stat_scan_tables
pg_read_server_files
pg_write_server_files
pg_execute_server_program
pg_signal_backend

and also role:
postgres*/

SELECT * 
FROM information_schema.table_privileges;

/*

ALL PRIVILEGES IS granted by grantor postgres TO the grantee postgres in all created schemas, because postgres is owner (superuser) of the database.
All privileges of postgres are grantable - postgres can grant them to other users

Also to the grantee PUBLIC  is granted privilegy SELECT for the tables of schema pg_catalog and tables of information_schema.
This privileges are not grantable.  
*/ 

-- command \du shows this:
/*
 List of roles
   Role name    |                         Attributes                         | Member of 
----------------+------------------------------------------------------------+-----------
 postgres       | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
*/