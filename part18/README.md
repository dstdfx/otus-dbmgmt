# DB size estimation

Calculate current database size (10 customers, ~3 orders for each):
```sql
mysql> SELECT table_schema AS "Database",  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)"  FROM information_schema.TABLES WHERE table_schema = "otusdb";
+----------+-----------+
| Database | Size (MB) |
+----------+-----------+
| otusdb   |      2.80 |
+----------+-----------+
1 row in set (0.00 sec)
```

Database size growing for 100 new customers in week per month ~1.1 GB.

# Replication and backups
1 master, 2 read-only replicas.
Backups and OLAP-related stuff are allowed only for replicas to reduce master-instance excess load.
