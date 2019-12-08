USE otusdb;

# We can't use foreign keys on partitioned table because of limitations:
# https://dev.mysql.com/doc/refman/8.0/en/partitioning-limitations.html
ALTER TABLE `orders` DROP FOREIGN KEY `orders_ibfk_1`;
ALTER TABLE `orders` DROP FOREIGN KEY `orders_ibfk_2`;
ALTER TABLE `orders` DROP FOREIGN KEY `orders_ibfk_3`;
ALTER TABLE `orders` DROP FOREIGN KEY `orders_ibfk_4`;

ALTER TABLE `orders` PARTITION BY RANGE COLUMNS(`created_at`) (
    PARTITION y2016 VALUES LESS THAN ('2016-01-01'),
    PARTITION y2017 VALUES LESS THAN ('2017-01-01'),
    PARTITION y2018 VALUES LESS THAN ('2018-01-01'),
    PARTITION y2019 VALUES LESS THAN ('2019-01-01'),
    PARTITION y20xx VALUES LESS THAN MAXVALUE
);
