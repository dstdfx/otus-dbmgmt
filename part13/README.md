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

## Changelog

Add `description` column to `products` table.
Add full-text index on `products` table (`name`, `description` fields).

Deleted redundant index on `customers`.`email`: 
```sql
mysql> use sys;
mysql> select * from schema_redundant_indexes\G;
*************************** 1. row ***************************
              table_schema: otusdb
                table_name: customers
      redundant_index_name: idx_customers_email
   redundant_index_columns: email
redundant_index_non_unique: 0
       dominant_index_name: email
    dominant_index_columns: email
 dominant_index_non_unique: 0
            subpart_exists: 0
            sql_drop_index: ALTER TABLE `otusdb`.`customers` DROP INDEX `idx_customers_email`
1 row in set (0.01 sec)
mysql> ALTER TABLE `otusdb`.`customers` DROP INDEX `idx_customers_email`;
Query OK, 0 rows affected (0.07 sec)
Records: 0  Duplicates: 0  Warnings: 0
```

## Full-text search example

Implemented in [3-full-text-search.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part13/docker-entrypoint-initdb.d/3-full-text-search.sql).

```sql
mysql> select bin_to_uuid(id), name, description from products where match(name,description) against('A world');
+--------------------------------------+-------------+-------------+
| bin_to_uuid(id)                      | name        | description |
+--------------------------------------+-------------+-------------+
| 3c9831d8-2338-11ea-8b8b-0242ac1d0002 | Product A_1 | Hello world |
| 3c98323c-2338-11ea-8b8b-0242ac1d0002 | Product A_2 | Hello world |
| 3c983291-2338-11ea-8b8b-0242ac1d0002 | Product A_3 | Hello world |
+--------------------------------------+-------------+-------------+
3 rows in set (0.01 sec)

mysql> explain select bin_to_uuid(id), name, description from products where match(name,description) against('A world')\G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: products
   partitions: NULL
         type: fulltext
possible_keys: products_full_text_idx
          key: products_full_text_idx
      key_len: 0
          ref: const
         rows: 1
     filtered: 100.00
        Extra: Using where; Ft_hints: sorted
1 row in set, 1 warning (0.00 sec)

mysql> select bin_to_uuid(id), name, description from products where match(name,description) against('adas A_1 wedw');
+--------------------------------------+-------------+-------------+
| bin_to_uuid(id)                      | name        | description |
+--------------------------------------+-------------+-------------+
| 3c9831d8-2338-11ea-8b8b-0242ac1d0002 | Product A_1 | Hello world |
+--------------------------------------+-------------+-------------+
1 row in set (0.00 sec)

mysql> select bin_to_uuid(id), name, description from products where match(name,description) against('12edwedew');
Empty set (0.01 sec)
```
