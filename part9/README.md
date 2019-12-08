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

# Changelog

### Partitioning

Added range partitioning for `orders` table by `created_at` by year.
It makes sense because in theory this table will have a huge amount of rows
and that's crucial for those kind of systems to be able to insert and find data
as fast as possible no matter how big database is.
As well as that, range partitioning by year might be useful for analytical goals, e.x:
reports and etc.

We can't use foreign keys on partitioned tables because of [limitations](https://dev.mysql.com/doc/refman/8.0/en/partitioning-limitations.html),
so we should get rid of them in `orders` table.
As well as that we can't use timezone-dependent expressions in (sub)partitioning function, thus we have to 
change `timestamp` type to `datetime`.

```sql
mysql> EXPLAIN SELECT * FROM `orders`\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: orders
   partitions: y2016,y2017,y2018,y2019,y20xx
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 1
     filtered: 100.00
        Extra: NULL
1 row in set, 1 warning (0.00 sec)
```

### JSON

Added JSON field `attributes` into `products`. This field represents a variety of additional attributes
that differs from product to product.

Insert example:
```sql
CREATE TABLE `products` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp,
  `deleted_at` timestamp,
  `name` varchar(255) NOT NULL,
  `category_id` BINARY(16) NOT NULL,
  `brand_id` BINARY(16) NOT NULL,
  `provider_id` BINARY(16) NOT NULL,
  `attributes` JSON NOT NULL
);

INSERT INTO `products`(`id`,`name`, `category_id`, `brand_id`, `provider_id`, `attributes`)
VALUES (
    UUID_TO_BIN(UUID()),
    'Macbook Pro 16',
    UUID_TO_BIN('aa047367-9ced-4ca1-9aec-0b5a6c8293c9'),
    UUID_TO_BIN('214debe4-7525-4af3-92e9-d709256c8648'),
    UUID_TO_BIN('434592a9-f648-453a-abce-75253169ce61'),
    '{"screen": "16 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 3, "usb": 0}}'
);

-- Same using JSON_OBJECT
INSERT INTO `products`(`id`, `name`, `category_id`, `brand_id`, `provider_id`, `attributes`)
VALUES (
    UUID_TO_BIN(UUID()),
    'Macbook Pro 16',
    UUID_TO_BIN('aa047367-9ced-4ca1-9aec-0b5a6c8293c9'),
    UUID_TO_BIN('214debe4-7525-4af3-92e9-d709256c8648'),
    UUID_TO_BIN('434592a9-f648-453a-abce-75253169ce61'),
    JSON_OBJECT(
        'screen', '16 inch',
        'resolution', '3072 x 1920 pixels',
        'ports', JSON_OBJECT('thunderbolt', 3, 'usb', 0)
    )
);

-- Same using JSON_MERGE and JSON_OBJECT
INSERT INTO `products`(`id`, `name`, `category_id`, `brand_id`, `provider_id`, `attributes`)
VALUES (
    UUID_TO_BIN(UUID()),
    'Macbook Pro 16',
    UUID_TO_BIN('aa047367-9ced-4ca1-9aec-0b5a6c8293c9'),
    UUID_TO_BIN('214debe4-7525-4af3-92e9-d709256c8648'),
    UUID_TO_BIN('434592a9-f648-453a-abce-75253169ce61'),
    JSON_MERGE(
        JSON_OBJECT('screen', '16 inch'),
        JSON_OBJECT('resolution', '3072 x 1920 pixels'),
        JSON_OBJECT('ports', JSON_OBJECT('thunderbolt', 3, 'usb', 0))
    )
);
```

Read example:
```sql
SELECT * FROM `products`
WHERE
    `category_id` = UUID_TO_BIN('aa047367-9ced-4ca1-9aec-0b5a6c8293c9') AND
    JSON_EXTRACT(`attributes` , '$.ports.usb') > 0;
```

Update example:
```sql
UPDATE `products`
SET `attributes` = JSON_INSERT(
    `attributes` ,
    '$.chipset' ,
    'Qualcomm'
)
WHERE
    `category_id` = UUID_TO_BIN('aa047367-9ced-4ca1-9aec-0b5a6c8293c9')
```

Delete example:
```sql
UPDATE `products`
SET `attributes` = JSON_REMOVE(`attributes` , '$.screen')
WHERE
    `category_id` = UUID_TO_BIN('aa047367-9ced-4ca1-9aec-0b5a6c8293c9');
```