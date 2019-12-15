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

# Queries

Get a customer_id <-> order_id mapping of not deleted orders:
```sql
SELECT BIN_TO_UUID(c.id) AS customer_id, BIN_TO_UUID(o.id) AS order_id
FROM customers AS c
INNER JOIN orders AS o ON c.id = o.customer_id
WHERE o.deleted_at is NULL;
```

Get a mapping of all customers and their orders:
```sql
SELECT BIN_TO_UUID(c.id) AS customer_id, BIN_TO_UUID(o.id) AS order_id
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id;
```

Get a list of customers filtered by their `correspondence_language`:
```sql
SELECT BIN_TO_UUID(id), email, correspondence_language
FROM customers
WHERE correspondence_language IN ('FR', 'IT', 'HU', 'EN');
```

Get a list of customers which have completed order with
more that 1 and less then 5 items in the order.
E.x: we can send them some kind of 'special offers'.
```sql
SELECT DISTINCT BIN_TO_UUID(c.id) AS customer_id, c.email AS customer_email
FROM orders AS o INNER JOIN customers AS c ON c.id = o.customer_id
WHERE (quantity BETWEEN 2 AND 5) AND o.status = 'COMPLETED';
```

Get all customers that have birthday today:
```sql
SELECT email, title, first_name, last_name
FROM customers
WHERE month(birth_date) = month(now()) AND day(birth_date) = day(now());
```

Get all orders that were created after specific period in time:
```sql
SELECT BIN_TO_UUID(id) AS order_id
FROM orders
WHERE created_at > TIMESTAMP('2019-12-14');
```

Get all orders that were completed after specific period of time:
```sql
SELECT BIN_TO_UUID(id) AS order_id
FROM orders
WHERE updated_at > TIMESTAMP('2018-10-10') AND status = 'COMPLETED';
```

