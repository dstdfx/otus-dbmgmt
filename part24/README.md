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
[0-init-schema.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part24/docker-entrypoint-initdb.d/0-init-schema.sql)

Test data to be inserted:
[1-init-data.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part24/docker-entrypoint-initdb.d/1-init-data.sql)


# Tasks

All queries might be found here:
[2-queries.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part24/docker-entrypoint-initdb.d/2-queries.sql)

Query with `crosstab`

Find amount of registered customers by `gender` for "2019" and "2020" years

```sql
otusdb=# select * from crosstab(
otusdb(#     'select
otusdb'#         gender, cast(extract(YEAR from created_at) as int) as created_year,
otusdb'#         count(*) as cnt
otusdb'#         from customers group by gender, created_year order by 1', $$VALUES('2019'::text), ('2020'::text)$$)
otusdb-#         AS (gender genders, "2019" text, "2020" text);
 gender | 2019 | 2020
--------+------+------
 male   |      | 2
 female |      | 6
(2 rows)
```

Query with `RANK` и `ROW_NUMBER()`

```sql
otusdb=# select rank() over (order by id), id, first_name from customers;
 rank |                  id                  |      first_name
------+--------------------------------------+-----------------------
    1 | 1c96de63-b5e0-41f8-ae72-5e1f6d4596e6 | Customer_G_First_Name
    2 | 1e85792d-f436-438e-a6b0-b6f4d6660ede | Customer_C_First_Name
    3 | 21c27f4d-a830-4d5d-80ae-004f2aaa5926 | Customer_I_First_Name
    4 | 91a3999a-9048-4d92-9922-1858f8642525 | Customer_D_First_Name
    5 | a8baa640-a21b-4a92-a0f7-02b3beebfdb6 | Customer_B_First_Name
    6 | ae885a46-2fd2-47de-bd09-f1b60b69d292 | Customer_J_First_Name
    7 | b6d6f262-de7d-4a5c-8bab-dafb587df89c | Customer_A_First_Name
    8 | b75854af-e70e-42fc-9876-068af3794643 | Customer_F_First_Name
(8 rows)
```

```sql
otusdb=# select row_number() over (order by id), id, first_name from customers;
 row_number |                  id                  |      first_name
------------+--------------------------------------+-----------------------
          1 | 1c96de63-b5e0-41f8-ae72-5e1f6d4596e6 | Customer_G_First_Name
          2 | 1e85792d-f436-438e-a6b0-b6f4d6660ede | Customer_C_First_Name
          3 | 21c27f4d-a830-4d5d-80ae-004f2aaa5926 | Customer_I_First_Name
          4 | 91a3999a-9048-4d92-9922-1858f8642525 | Customer_D_First_Name
          5 | a8baa640-a21b-4a92-a0f7-02b3beebfdb6 | Customer_B_First_Name
          6 | ae885a46-2fd2-47de-bd09-f1b60b69d292 | Customer_J_First_Name
          7 | b6d6f262-de7d-4a5c-8bab-dafb587df89c | Customer_A_First_Name
          8 | b75854af-e70e-42fc-9876-068af3794643 | Customer_F_First_Name
(8 rows)
```

Select max/min product price for each category using window functions

```sql
otusdb=# \x
Expanded display is on.
otusdb=#
otusdb=# select distinct
otusdb-#     first_value(p.id) over (partition by category_id order by pr.amount desc) as max_product_id,
otusdb-#     c.id as category_id, max(pr.amount) over (partition by category_id) as max_product_price,
otusdb-#     first_value(p.id) over (partition by category_id order by pr.amount asc) as min_product_id,
otusdb-#     min(pr.amount) over (partition by category_id) as min_product_price
otusdb-# from categories as c
otusdb-#     inner join products as p on p.category_id = c.id
otusdb-#     inner join provider_products as pp on pp.product_id = p.id
otusdb-#     inner join prices as pr on pr.id = pp.price_id
otusdb-# order by category_id;
-[ RECORD 1 ]-----+-------------------------------------
max_product_id    | 9c96737b-9fa3-4dc9-9677-1b5326341f1d
category_id       | 2edf4e9b-8152-4c4a-9291-66f0f63f677a
max_product_price | 5499.00
min_product_id    | 9c96737b-9fa3-4dc9-9677-1b5326341f1d
min_product_price | 2490.80
-[ RECORD 2 ]-----+-------------------------------------
max_product_id    | cb0b93d1-5959-424a-b33c-7965c493640a
category_id       | 7ef86644-4cf4-4e73-af97-df02c17d1879
max_product_price | 1799.00
min_product_id    | cb0b93d1-5959-424a-b33c-7965c493640a
min_product_price | 350.00
-[ RECORD 3 ]-----+-------------------------------------
max_product_id    | bb78cd63-5887-4f03-9fe2-f8d83a993c65
category_id       | 859735a6-69ca-48b8-8662-91aa4be8c652
max_product_price | 7499.00
min_product_id    | bb78cd63-5887-4f03-9fe2-f8d83a993c65
min_product_price | 6599.00
```

Divide customers by N groups by `correspondence_language`

```sql
otusdb=# select
otusdb-#        row_number() over (partition by correspondence_language order by first_name) as group_id,
otusdb-#        id,
otusdb-#        correspondence_language
otusdb-# from customers;
 group_id |                  id                  | correspondence_language
----------+--------------------------------------+-------------------------
        1 | 6d763b57-612e-4c23-b6fd-53f1b8ef1d35 | EN
        2 | 75586241-c96a-42bc-9db0-83a825897952 | EN
        3 | 109a62c6-b642-4b9f-ba19-b1faf6cfcf62 | EN
        1 | acac6c6a-a5d6-46f2-8875-cd6a87e679b1 | IT
        1 | ac8ba323-b58c-4130-a564-38cc415efd30 | CS
        1 | 8eb9873d-cf46-4c7e-98a3-5eda8920ebdb | DE
        1 | 4eae1427-e7b8-4a7e-ba4a-8d4224f33d1c | PL
        1 | e169f014-2501-4134-b185-cc80f6d43f7f | FR
(8 rows)
```
