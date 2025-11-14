-- Enable query cache
UPDATE mysql_query_rules SET cache_ttl=300 WHERE rule_id=1;

-- Set global cache parameters
UPDATE global_variables SET variable_value='1000' WHERE variable_name='mysql-query_cache_size_MB';
UPDATE global_variables SET variable_value='1' WHERE variable_name='mysql-query_cache_stores_empty_result';

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;


MySQL [(none)]> SELECT * FROM global_variables WHERE variable_name LIKE 'mysql-query_cache%';
+---------------------------------------+----------------+
| variable_name                         | variable_value |
+---------------------------------------+----------------+
| mysql-query_cache_size_MB             | 1000           |
| mysql-query_cache_soft_ttl_pct        | 0              |
| mysql-query_cache_handle_warnings     | 0              |
| mysql-query_cache_stores_empty_result | 1              |
+---------------------------------------+----------------+
4 rows in set (0.011 sec)


-- Cache all SELECT queries for 60 seconds
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, cache_ttl, apply)
VALUES (10, 1, '^SELECT', 60000, 1);
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;




-- Cache all read queries on reader hostgroup
UPDATE mysql_query_rules 
SET cache_ttl=30000 
WHERE destination_hostgroup=READER_HOSTGROUP_ID 
AND match_pattern='^SELECT';

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

-- cache status.

SELECT * FROM stats_mysql_global WHERE Variable_Name LIKE 'Query_Cache%';



MySQL [(none)]> SELECT * FROM stats_mysql_global WHERE Variable_Name LIKE 'Query_Cache%';
+--------------------------+----------------+
| Variable_Name            | Variable_Value |
+--------------------------+----------------+
| Query_Cache_Memory_bytes | 168324         |
| Query_Cache_count_GET    | 28             |
| Query_Cache_count_GET_OK | 26             |
| Query_Cache_count_SET    | 2              |
| Query_Cache_bytes_IN     | 161156         |
| Query_Cache_bytes_OUT    | 2095028        |
| Query_Cache_Purged       | 0              |
| Query_Cache_Entries      | 2              |
+--------------------------+----------------+
8 rows in set (0.003 sec)



-- Enable general query log (temporary)
SET GLOBAL general_log = 'ON';
SET GLOBAL general_log_file = '/tmp/mysql-query.log';

