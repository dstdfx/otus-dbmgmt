# Start

```sh
docker-compose up otusdb
```

# Connect

```sh
docker-compose exec otusdb mysql -u root -p12345 otusdb
```

# Stop

```sh
docker-compose down -v --remove-orphans
```

## Transaction within procedure

Implemented in [2-procedure.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part11/docker-entrypoint-initdb.d/2-procedure.sql).

`update_customer_email_with_log` updates customer email and stores info into `log_action` table within a transaction.

Get current customer's ids and emails:
```sql
mysql> select BIN_TO_UUID(id), email from customers;
+--------------------------------------+---------------------+
| BIN_TO_UUID(id)                      | email               |
+--------------------------------------+---------------------+
| 284ff4b2-20aa-11ea-b538-0242c0a8a002 | example_a@gmail.com |
| 284ff66c-20aa-11ea-b538-0242c0a8a002 | example_b@gmail.com |
| 284ff6dd-20aa-11ea-b538-0242c0a8a002 | example_c@gmail.com |
| 284ff749-20aa-11ea-b538-0242c0a8a002 | example_d@gmail.com |
| 284ff7ce-20aa-11ea-b538-0242c0a8a002 | example_e@gmail.com |
+--------------------------------------+---------------------+
5 rows in set (0.00 sec)
```

Update customer's email via procedure:
```sql
mysql> CALL update_customer_email_with_log(UUID_TO_BIN('284ff4b2-20aa-11ea-b538-0242c0a8a002'), 'changed_a@email.com');
Query OK, 0 rows affected (0.03 sec)
```

Check that email value has changed:
```sql
mysql> select BIN_TO_UUID(id), email from customers where id = UUID_TO_BIN('284ff4b2-20aa-11ea-b538-0242c0a8a002');
+--------------------------------------+---------------------+
| BIN_TO_UUID(id)                      | email               |
+--------------------------------------+---------------------+
| 284ff4b2-20aa-11ea-b538-0242c0a8a002 | changed_a@email.com |
+--------------------------------------+---------------------+
1 row in set (0.00 sec)
```

Check `log_actions` table:
```sql
mysql> select created_at, operation, description from log_actions;
+---------------------+----------------------+------------------------------------------------------------------------------+
| created_at          | operation            | description                                                                  |
+---------------------+----------------------+------------------------------------------------------------------------------+
| 2019-12-17 08:51:38 | CHANGE_PERSONAL_INFO | Customer has changed email from: example_a@gmail.com to: changed_a@email.com |
+---------------------+----------------------+------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

## Load data via `LOAD DATA` command

Implemented in [3-load-data-from-csv.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part11/docker-entrypoint-initdb.d/3-load-data-from-csv.sql).
