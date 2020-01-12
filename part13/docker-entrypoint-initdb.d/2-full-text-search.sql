USE otusdb;

-- add new column and update 3 rows
alter table `products` add column `description` varchar(300);
update `products` set `description` = 'Hello world' limit 3;

-- create full-text index
create fulltext index `products_full_text_idx` on `products`(`name`,`description`);

-- full-text search queries
explain select bin_to_uuid(id), name, description from products where match(name,description) against('A world')\G;
select bin_to_uuid(id), name, description from products where match(name,description) against('A world');
select bin_to_uuid(id), name, description from products where match(name,description) against('adas A_1 wedw');
select bin_to_uuid(id), name, description from products where match(name,description) against('12edwedew');

-- delete redurant index
ALTER TABLE `customers` DROP INDEX `idx_customers_email`;
