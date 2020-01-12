# Start

```sh
docker-compose up otusdb
```

# Connect

As 'client' user:
```sh
docker-compose exec otusdb mysql -u client -p12345 otusdb
```

As 'manager' user:
```sh
docker-compose exec otusdb mysql -u manager -p12345 otusdb
```

# Stop

```sh
docker-compose down -v --remove-orphans
```

## Procedures

Implemented in [2-procedures.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part15/docker-entrypoint-initdb.d/3-procedures.sql).

Fetch actual categories' id's. Note that they can differs from id's in example:
```sql
mysql> select bin_to_uuid(id), name from categories;
+--------------------------------------+---------------+
| bin_to_uuid(id)                      | name          |
+--------------------------------------+---------------+
| 59c89932-2dbb-11ea-979e-0242ac170002 | Category A    |
| 59c89988-2dbb-11ea-979e-0242ac170002 | Category B    |
| 59c899dd-2dbb-11ea-979e-0242ac170002 | Category C    |
| 59c898cc-2dbb-11ea-979e-0242ac170002 | Root category |
+--------------------------------------+---------------+
4 rows in set (0.00 sec)
```

Procedure `get_products` lists all products filtered by category_id, min/max price range. As well as that
it supports ordering by field and paging. Note that it must be called from 'client' user.
```sql
mysql> call get_products('59c89932-2dbb-11ea-979e-0242ac170002', 0, 5000, 'name', 100, 0);
+--------------------------------------+-------------+---------+--------------------------------------+
| id                                   | name        | price   | provider_id                          |
+--------------------------------------+-------------+---------+--------------------------------------+
| 59cbbc58-2dbb-11ea-979e-0242ac170002 | Product A_1 | 2490.80 | 59c68c1e-2dbb-11ea-979e-0242ac170002 |
| 59cbbcc8-2dbb-11ea-979e-0242ac170002 | Product A_2 | 2490.80 | 59c68c1e-2dbb-11ea-979e-0242ac170002 |
+--------------------------------------+-------------+---------+--------------------------------------+
2 rows in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

mysql> call get_products('59c89932-2dbb-11ea-979e-0242ac170002', 0, 6000, 'name', 100, 0);
+--------------------------------------+-------------+---------+--------------------------------------+
| id                                   | name        | price   | provider_id                          |
+--------------------------------------+-------------+---------+--------------------------------------+
| 59cbbc58-2dbb-11ea-979e-0242ac170002 | Product A_1 | 2490.80 | 59c68c1e-2dbb-11ea-979e-0242ac170002 |
| 59cbbc58-2dbb-11ea-979e-0242ac170002 | Product A_1 | 5999.00 | 59c68ca1-2dbb-11ea-979e-0242ac170002 |
| 59cbbcc8-2dbb-11ea-979e-0242ac170002 | Product A_2 | 2490.80 | 59c68c1e-2dbb-11ea-979e-0242ac170002 |
+--------------------------------------+-------------+---------+--------------------------------------+
3 rows in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

mysql> call get_products('59c89932-2dbb-11ea-979e-0242ac170002', 0, 6000, 'name', 1, 0);
+--------------------------------------+-------------+---------+--------------------------------------+
| id                                   | name        | price   | provider_id                          |
+--------------------------------------+-------------+---------+--------------------------------------+
| 59cbbc58-2dbb-11ea-979e-0242ac170002 | Product A_1 | 2490.80 | 59c68c1e-2dbb-11ea-979e-0242ac170002 |
+--------------------------------------+-------------+---------+--------------------------------------+
1 row in set (0.01 sec)

Query OK, 0 rows affected (0.01 sec)
```

Procedure `get_orders` lists all completed orders filtered by datetime range with different grouping options:
by product, category and customer id's. Note that it must be called from 'manager' user.
```sql
mysql> call get_orders('2019-01-01 20:28:39', '2021-01-01 20:28:39', true, false, false);
+--------------------------------------+--------------+----------+
| product_id                           | orders_count | total    |
+--------------------------------------+--------------+----------+
| 59cbbc58-2dbb-11ea-979e-0242ac170002 |            1 | 17495.00 |
| 59cbbd74-2dbb-11ea-979e-0242ac170002 |            1 | 19797.00 |
| 59cbbdca-2dbb-11ea-979e-0242ac170002 |            1 |  6599.00 |
| 59cbbe74-2dbb-11ea-979e-0242ac170002 |            1 |  3598.00 |
| summary                              |            4 | 47489.00 |
+--------------------------------------+--------------+----------+
5 rows in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

mysql> call get_orders('2019-01-01 20:28:39', '2021-01-01 20:28:39', false, true, false);
+--------------------------------------+--------------+----------+
| category_id                          | orders_count | total    |
+--------------------------------------+--------------+----------+
| 59c89932-2dbb-11ea-979e-0242ac170002 |            1 | 17495.00 |
| 59c89988-2dbb-11ea-979e-0242ac170002 |            2 | 26396.00 |
| 59c899dd-2dbb-11ea-979e-0242ac170002 |            1 |  3598.00 |
| summary                              |            4 | 47489.00 |
+--------------------------------------+--------------+----------+
4 rows in set (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

mysql> call get_orders('2019-01-01 20:28:39', '2021-01-01 20:28:39', false, false, true);
+--------------------------------------+--------------+----------+
| customer_id                          | orders_count | total    |
+--------------------------------------+--------------+----------+
| 59c3d925-2dbb-11ea-979e-0242ac170002 |            3 | 40890.00 |
| 59c3d9e0-2dbb-11ea-979e-0242ac170002 |            1 |  6599.00 |
| summary                              |            4 | 47489.00 |
+--------------------------------------+--------------+----------+
3 rows in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)
```
