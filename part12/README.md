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

## Views

Implemented in [3-views.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part12/docker-entrypoint-initdb.d/3-views.sql).

`products_offers_view` shows available products and offers info: offers count and max/min/avg prices.
Note, that there must be at least 2 offers for a product to be shown.

```sql
mysql> select * from products_offers_view;
+--------------------------------------+--------------+--------------+---------+---------+-------------+
| product_id                           | product_name | offers_count | max     | min     | avg         |
+--------------------------------------+--------------+--------------+---------+---------+-------------+
| 3c9831d8-2338-11ea-8b8b-0242ac1d0002 | Product A_1  |            2 | 5999.00 | 2490.80 | 4244.900000 |
| 3c98323c-2338-11ea-8b8b-0242ac1d0002 | Product A_2  |            3 | 7499.00 | 2490.80 | 5662.933333 |
| 3c983291-2338-11ea-8b8b-0242ac1d0002 | Product A_3  |            2 | 7499.00 | 6999.00 | 7249.000000 |
| 3c9832e6-2338-11ea-8b8b-0242ac1d0002 | Product B_1  |            2 | 5999.00 | 5499.00 | 5749.000000 |
| 3c98333b-2338-11ea-8b8b-0242ac1d0002 | Product B_2  |            3 | 7499.00 | 5499.00 | 6665.666667 |
| 3c98338f-2338-11ea-8b8b-0242ac1d0002 | Product B_3  |            2 | 7499.00 | 6999.00 | 7249.000000 |
| 3c9833e4-2338-11ea-8b8b-0242ac1d0002 | Product C_1  |            2 | 7499.00 | 5999.00 | 6749.000000 |
| 3c983438-2338-11ea-8b8b-0242ac1d0002 | Product C_2  |            3 | 7499.00 | 5499.00 | 6665.666667 |
| 3c98348d-2338-11ea-8b8b-0242ac1d0002 | Product C_3  |            2 | 6999.00 | 5499.00 | 6249.000000 |
+--------------------------------------+--------------+--------------+---------+---------+-------------+
9 rows in set (0.00 sec)
```

`categories_overview` show a summarize amount of products for each category and for all 

```sql
mysql> select * from categories_overview;
+---------------+---------------+
| category_name | product_count |
+---------------+---------------+
| Category A    |             3 |
| Category B    |             3 |
| Category C    |             3 |
| Summary       |             9 |
+---------------+---------------+
4 rows in set (0.01 sec)
``` 
