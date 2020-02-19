# Start

```sh
docker-compose up otusdb
```

# Connect

With interactive password input (default password is `otusdb`):
```sh
docker-compose exec postgres psql -h postgres -U otusdb
```
via URL:
```sh
docker-compose exec postgres psql "postgresql://otusdb:otusdb@postgres/otusdb"
```

# Stop

```sh
docker-compose down -v --remove-orphans
```

_Note that schema and test data will be set up automatically._

Schema:
[0-init-schema.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part23/docker-entrypoint-initdb.d/0-init-schema.sql)

Test data to be inserted:
[1-init-data.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part23/docker-entrypoint-initdb.d/1-init-data.sql)

# Queries

1. Regular expressions

Find customer id with `first_name` that starts with `Customer_A`:
```sql
otusdb=# select id, first_name from customers where first_name ~ 'Customer_A';
                  id                  |      first_name
--------------------------------------+-----------------------
 9726b10a-2420-4d0c-8ae9-1424fab89495 | Customer_A_First_Name
(1 row)
```
or using LIKE clause:
```sql
otusdb=# select id, first_name from customers where first_name LIKE 'Customer_A%';
                  id                  |      first_name
--------------------------------------+-----------------------
 9726b10a-2420-4d0c-8ae9-1424fab89495 | Customer_A_First_Name
(1 row)
```

2. Joins

For `INNER JOIN` table's order does not make sense.

```sql
otusdb=# select c.id as customer_id, c.email as customer_email
from orders as o inner join customers as c on c.id = o.customer_id
where (quantity between 5 AND 20) and o.status = 'COMPLETED';
             customer_id              |  customer_email
--------------------------------------+------------------
 9726b10a-2420-4d0c-8ae9-1424fab89495 | test-a@gmail.com
 4ede46c3-505f-4095-8711-18836e19a77a | test-c@gmail.com
(2 rows)
```

Equals to the query above:
```sql
otusdb=# select c.id as customer_id, c.email as customer_email
from customers as c inner join orders as o on c.id = o.customer_id
where (quantity between 5 AND 20) and o.status = 'COMPLETED';
             customer_id              |  customer_email
--------------------------------------+------------------
 9726b10a-2420-4d0c-8ae9-1424fab89495 | test-a@gmail.com
 4ede46c3-505f-4095-8711-18836e19a77a | test-c@gmail.com
(2 rows)
```

For `LEFT JOIN` table's order makes sense.

Joins all the values from `products` table matched by `foreign key` with `categories` table:
```sql
otusdb=# select p.id as product_id, c.name as category_name from products as p left join categories as c on p.category_id = c.id;
              product_id              | category_name
--------------------------------------+---------------
 a0bd1915-736c-4fe7-8eea-41cd11e63d34 | Category_A
 1b99c13a-5ba7-42bb-8a78-0737080a91fd | Category_A
 65045b7f-6c4c-415f-9a7e-08d565e3f44d | Category_A
 4c71e396-e3a9-4468-aa8d-ff4a42e512c9 | Category_B
 9658af3b-76f9-47e2-bdca-37427c4939f2 | Category_B
 f9e07e3c-c177-4067-9968-441453d285cc | Category_B
 6c65f87d-15df-457e-a56e-e2691d7ebe8a | Category_C
 bf978328-987c-4454-b382-1e12586e8bb1 | Category_C
 97d882c4-4b38-4535-8195-2ba1b0242de5 | Category_C
(9 rows)
```

Reversed order, `categories` table goes first.
Joins all values from `categories` table matched by `foreign key` with `products` table:
```sql
otusdb=# select c.name as category_name, p.id as product_id from categories as c left join products as p on p.category_id = c.id;
 category_name |              product_id
---------------+--------------------------------------
 Category_A    | a0bd1915-736c-4fe7-8eea-41cd11e63d34
 Category_A    | 1b99c13a-5ba7-42bb-8a78-0737080a91fd
 Category_A    | 65045b7f-6c4c-415f-9a7e-08d565e3f44d
 Category_B    | 4c71e396-e3a9-4468-aa8d-ff4a42e512c9
 Category_B    | 9658af3b-76f9-47e2-bdca-37427c4939f2
 Category_B    | f9e07e3c-c177-4067-9968-441453d285cc
 Category_C    | 6c65f87d-15df-457e-a56e-e2691d7ebe8a
 Category_C    | bf978328-987c-4454-b382-1e12586e8bb1
 Category_C    | 97d882c4-4b38-4535-8195-2ba1b0242de5
 Root_Category |
(10 rows)
```
3. Update

Update `customers` that has `orders`:
```sql
otusdb=# update customers set updated_at = now() from orders where orders.customer_id = customers.id;
UPDATE 3
```

Check:
```sql
otusdb=# select id, updated_at from customers;
                  id                  |         updated_at
--------------------------------------+----------------------------
 9726b10a-2420-4d0c-8ae9-1424fab89495 | 2020-02-18 19:24:25.170335
 1a97ea50-7a28-4f2a-8596-f7b0e9b01d39 | 2020-02-18 19:24:25.170335
 4ede46c3-505f-4095-8711-18836e19a77a | 2020-02-18 19:24:25.170335
(3 rows)
```

4. Delete

Delete `orders` with specific `customer_id` and in `COMPLETED` status:
```sql
otusdb=# delete from orders as o using customers as c where o.customer_id = c.id and c.id = '9726b10a-2420-4d0c-8ae9-1424fab89495' and o.status = 'COMPLETED';
DELETE 3
```

Check:
```sql
otusdb=# select id, status, customer_id from orders;
                  id                  |   status   |             customer_id
--------------------------------------+------------+--------------------------------------
 46e1fb91-7cf5-4c00-a894-64ecdaf20402 | PROCESSING | 1a97ea50-7a28-4f2a-8596-f7b0e9b01d39
 808c188f-32db-4e22-8cbc-a24ba1376a0c | ON_HOLD    | 4ede46c3-505f-4095-8711-18836e19a77a
 d2578536-58b6-4e44-9e60-846302c12fa8 | COMPLETED  | 4ede46c3-505f-4095-8711-18836e19a77a
(3 rows)
```

5. Copy

Make dump from `orders` table:
```sql
otusdb=# copy orders to '/var/lib/postgresql/dump_orders.csv';
COPY 3
```

Check that file has been created in the system:
```sh
docker-compose exec postgres sh
# cat /var/lib/postgresql/dump_orders.csv
46e1fb91-7cf5-4c00-a894-64ecdaf20402	2020-02-18 19:31:16.609071	\N	\N	1a97ea50-7a28-4f2a-8596-f7b0e9b01d39	a0bd1915-736c-4fe7-8eea-41cd11e63d34	83273400-83cf-4891-8eb6-a526ce6cd828	d9c47d5d-6d87-412a-9ada-4b2d27b48cdc	2	PROCESSING
808c188f-32db-4e22-8cbc-a24ba1376a0c	2020-02-18 19:31:16.609071	\N	\N	4ede46c3-505f-4095-8711-18836e19a77a	6c65f87d-15df-457e-a56e-e2691d7ebe8a	762045f2-19d3-4b39-93fa-33ea0e4d5429	ed723296-9bf2-4a6c-b00e-e9b5cab01b1e	30	ON_HOLD
d2578536-58b6-4e44-9e60-846302c12fa8	2020-02-18 19:31:16.609071	\N	\N	4ede46c3-505f-4095-8711-18836e19a77a	4c71e396-e3a9-4468-aa8d-ff4a42e512c9	ac6ee297-e78a-4e8b-b4ef-189d1f7036d1	ed723296-9bf2-4a6c-b00e-e9b5cab01b1e	17	COMPLETED
```

Delete all rows from `orders`:
```sql
otusdb=# delete from orders;
DELETE 3
```

Recover values from CSV dump:
```sql
otusdb=# copy orders from '/var/lib/postgresql/dump_orders.csv' delimiter E'\t';
COPY 3
```

Check that values have been recovered: 
```sql
otusdb=# select id, created_at, status from orders;
                  id                  |         created_at         |   status
--------------------------------------+----------------------------+------------
 46e1fb91-7cf5-4c00-a894-64ecdaf20402 | 2020-02-18 19:31:16.609071 | PROCESSING
 808c188f-32db-4e22-8cbc-a24ba1376a0c | 2020-02-18 19:31:16.609071 | ON_HOLD
 d2578536-58b6-4e44-9e60-846302c12fa8 | 2020-02-18 19:31:16.609071 | COMPLETED
(3 rows)
```
