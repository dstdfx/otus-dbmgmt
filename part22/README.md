# Start

```sh
docker-compose up otusdb
```

# Connect

With interactive password input (default password is `postgres`):
```sh
docker-compose exec postgres psql -h postgres -U postgres
```
via URL:
```sh
docker-compose exec postgres psql "postgresql://postgres:postgres@postgres/postgres"
```

# Stop

```sh
docker-compose down -v --remove-orphans
```

# Create user

```sql
CREATE USER store_admin WITH SUPERUSER LOGIN PASSWORD '123';
```

We need to create superuser because it's required to be able to 
create extensions (e.x "uuid-ossp") and so on.

# Create tablespace

```sql
CREATE TABLESPACE store_ts OWNER store_admin LOCATION '/var/lib/postgresql/data';
```

# Create database 

```sql
CREATE DATABASE store_db WITH OWNER = store_admin TABLESPACE = store_ts;
```

# Connect to created DB as `store_admin`

```sh
docker-compose exec postgres psql "postgresql://store_admin:123@postgres/store_db" 
```

# Apply schema from SQL file

```sh
store_db=# \i /var/lib/postgresql/schema/shop_schema.sql
```

Applied schema: [shop_schema.sql](https://github.com/dstdfx/otus-dbmgmt/blob/master/part22/schema/shop_schema.sql)

# Result

```sql
store_db=# \d
                 List of relations
 Schema |        Name        | Type  |    Owner
--------+--------------------+-------+-------------
 public | addresses          | table | store_admin
 public | brands             | table | store_admin
 public | buildings          | table | store_admin
 public | categories         | table | store_admin
 public | cities             | table | store_admin
 public | countries          | table | store_admin
 public | currencies         | table | store_admin
 public | customer_addresses | table | store_admin
 public | customers          | table | store_admin
 public | manufacturers      | table | store_admin
 public | orders             | table | store_admin
 public | prices             | table | store_admin
 public | products           | table | store_admin
 public | provider_products  | table | store_admin
 public | providers          | table | store_admin
 public | regions            | table | store_admin
 public | streets            | table | store_admin
(17 rows)
```
