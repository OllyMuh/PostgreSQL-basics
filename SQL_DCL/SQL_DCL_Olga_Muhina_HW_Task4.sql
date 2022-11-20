/*
4. Prepare answers to the following questions:
• How can one restrict access to certain columns of a database table?

 Implement column-level sequrity
 grant select (col1, col2, col3) on name_of_table to name_of_role; -- we allow only current columns of table


• What is the difference between user identification and user authentication?

Authentication is a process of validating an identity. This generally means verifying that a user or entity is who they say they are
providing something secret they know (like passwords).

While authentication is concerned with validating identity, authorization focuses on controlling what capabilities are associated
with those identities or accounts. Once you know who someone is, the authorization functionality determines what they can do.


• What are the recommended authentication protocols for PostgreSQL?

1. trust		for all users without passwords
2. password		by passsword of database user
3. GSSAPI		???
4. SSPI			???
5. ident		for TCP/IP servers login - name of user = name of system user
6. peer			login by name of user = name of system user
7. LDAP			???
8. RADIUS		???
9. sertificate	for SSL-connections with the clients sertificate SSL
10. PAM			???
11. BSD			???


• What is proxy authentication in PostgreSQL and what is it for? Why does it make the previously discussed role-based access control easier to
implement?
	
Often, when designing an application, a login role is used to configure database connections and connection tools. 
Another level of security needs to be implemented to ensure that the user who uses the application is authorized to perform a certain task. 
This logic is often implemented in application business logic.

The database's role system can also be used to partially implement this logic by delegating the authentication to another role 
after the connection is established or reused.
**/