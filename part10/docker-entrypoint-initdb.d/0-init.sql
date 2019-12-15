CREATE DATABASE IF NOT EXISTS otusdb;
USE otusdb;

CREATE TABLE `customers` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `title` ENUM('Mr','Mrs','Ms','Miss') COMMENT 'customer titile, used in emails',
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `gender` ENUM('male', 'female') NOT NULL,
  `birth_date` DATETIME NOT NULL CHECK (`birth_date` > '1900-01-01'),
  `email` VARCHAR(255) UNIQUE NOT NULL,
  `marital_status` ENUM('married', 'single', 'divorced', 'widowed'),
  `correspondence_language` ENUM ('RU', 'EN', 'IT', 'CS', 'DE', 'PL', 'FR', 'NL', 'HU') COMMENT 'language that is used in emails'
);

CREATE TABLE `customer_addresses` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `address_id` BINARY(16) NOT NULL,
  `customer_id` BINARY(16) NOT NULL,
  `is_default` BOOL COMMENT 'if flag is true - this address will be passed to all new orders by default'
);

CREATE TABLE `addresses` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `building_id` BINARY(16) NOT NULL,
  `postal_code` VARCHAR(255)
);

CREATE TABLE `countries` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `name` VARCHAR(255) NOT NULL
);

CREATE TABLE `regions` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `name` VARCHAR(255) NOT NULL,
  `country_id` BINARY(16) NOT NULL
);

CREATE TABLE `cities` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `name` VARCHAR(255) NOT NULL,
  `region_id` BINARY(16) NOT NULL
);

CREATE TABLE `streets` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `name` VARCHAR(255) NOT NULL,
  `city_id` BINARY(16) NOT NULL
);

CREATE TABLE `buildings` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `number` INT UNSIGNED NOT NULL,
  `litera` VARCHAR(2),
  `street_id` BINARY(16) NOT NULL
);

CREATE TABLE `products` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `name` VARCHAR(255) NOT NULL,
  `category_id` BINARY(16) NOT NULL,
  `brand_id` BINARY(16) NOT NULL,
  `provider_id` BINARY(16) NOT NULL,
  `attributes` JSON NOT NULL
);

CREATE TABLE `provider_products` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `product_id` BINARY(16) NOT NULL,
  `provider_id` BINARY(16) NOT NULL,
  `price_id` BINARY(16) NOT NULL COMMENT 'providers price for the product'
);

CREATE TABLE `prices` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `amount` NUMERIC(15, 2) NOT NULL COMMENT 'amount of the price',
  `currency_id` BINARY(16) NOT NULL
);

CREATE TABLE `currencies` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `code` VARCHAR(255) NOT NULL COMMENT 'code of the currency',
  `cbr_name` VARCHAR(255) NOT NULL COMMENT 'central bank of the currency',
  `rate` VARCHAR(255) NOT NULL COMMENT 'rate of the currency'
);

CREATE TABLE `categories` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `parent_id` BINARY(16) COMMENT 'parent category',
  `name` VARCHAR(255) NOT NULL
);

CREATE TABLE `orders` (
  `id` BINARY(16),
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `customer_id` BINARY(16) NOT NULL COMMENT 'customer which makes the order',
  `product_id` BINARY(16) NOT NULL COMMENT 'product in the order',
  `price_id` BINARY(16) NOT NULL COMMENT 'price for which one item of the product was purchased',
  `address_id` BINARY(16) NOT NULL COMMENT 'order address',
  `quantity` INT UNSIGNED NOT NULL CHECK (`quantity` > 0) COMMENT 'quantity of a product in the order',
  `status` ENUM('ON_HOLD', 'PROCESSING', 'COMPLETED') DEFAULT 'ON_HOLD' COMMENT 'status of the order',
  PRIMARY KEY (`id`, `created_at`)
);

CREATE TABLE `manufacturers` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `contact_number` VARCHAR(15) NOT NULL,
  `address_id` BINARY(16) NOT NULL
);

CREATE TABLE `brands` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `contact_number` VARCHAR(15) NOT NULL,
  `manufacturer_id` BINARY(16) NOT NULL
);

CREATE TABLE `providers` (
  `id` BINARY(16) PRIMARY KEY,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME,
  `deleted_at` DATETIME,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `contact_number` VARCHAR(15) NOT NULL,
  `address_id` BINARY(16) NOT NULL COMMENT 'address of the provider'
);

ALTER TABLE `customer_addresses` ADD FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`);

ALTER TABLE `customer_addresses` ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`);

ALTER TABLE `addresses` ADD FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`);

ALTER TABLE `regions` ADD FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`);

ALTER TABLE `cities` ADD FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`);

ALTER TABLE `streets` ADD FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`);

ALTER TABLE `buildings` ADD FOREIGN KEY (`street_id`) REFERENCES `streets` (`id`);

ALTER TABLE `products` ADD FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

ALTER TABLE `products` ADD FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`);

ALTER TABLE `products` ADD FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`);

ALTER TABLE `provider_products` ADD FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

ALTER TABLE `provider_products` ADD FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`);

ALTER TABLE `provider_products` ADD FOREIGN KEY (`price_id`) REFERENCES `prices` (`id`);

ALTER TABLE `prices` ADD FOREIGN KEY (`currency_id`) REFERENCES `currencies` (`id`);

ALTER TABLE `categories` ADD FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`);

ALTER TABLE `orders` ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`);

ALTER TABLE `orders` ADD FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

ALTER TABLE `orders` ADD FOREIGN KEY (`price_id`) REFERENCES `prices` (`id`);

ALTER TABLE `orders` ADD FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`);

ALTER TABLE `manufacturers` ADD FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`);

ALTER TABLE `brands` ADD FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`);

ALTER TABLE `providers` ADD FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`);

CREATE INDEX `idx_customers_created_at` ON `customers` (`created_at`);

CREATE UNIQUE INDEX `idx_customers_email` ON `customers` (`email`);

CREATE INDEX `idx_customer_addresses_created_at` ON `customer_addresses` (`created_at`);

CREATE UNIQUE INDEX `idx_customer_addresses_address_id_customer_id` ON `customer_addresses` (`address_id`, `customer_id`);

CREATE INDEX `idx_addresses_building_id` ON `addresses` (`building_id`);

CREATE INDEX `idx_addresses_postal_code` ON `addresses` (`postal_code`);

CREATE INDEX `idx_regions_country_id` ON `regions` (`country_id`);

CREATE INDEX `idx_cities_region_id` ON `cities` (`region_id`);

CREATE INDEX `idx_streets_city_id` ON `streets` (`city_id`);

CREATE INDEX `idx_buildings_street_id` ON `buildings` (`street_id`);

CREATE INDEX `idx_products_created_at` ON `products` (`created_at`);

CREATE INDEX `idx_products_category_id` ON `products` (`category_id`);

CREATE INDEX `idx_products_brand_id` ON `products` (`brand_id`);

CREATE INDEX `idx_products_provider_id` ON `products` (`provider_id`);

CREATE INDEX `idx_provider_products_created_at` ON `provider_products` (`created_at`);

CREATE UNIQUE INDEX `idx_provider_products_product_id_provider_id` ON `provider_products` (`product_id`, `provider_id`);

CREATE INDEX `idx_provider_products_price_id` ON `provider_products` (`price_id`);

CREATE INDEX `idx_prices_currency_id` ON `prices` (`currency_id`);

CREATE INDEX `idx_categories_name` ON `categories` (`name`);

CREATE INDEX `idx_categories_parent_id` ON `categories` (`parent_id`);

CREATE INDEX `idx_orders_created_at` ON `orders` (`created_at`);

CREATE INDEX `idx_orders_customer_id_product_id` ON `orders` (`customer_id`, `product_id`);

CREATE INDEX `idx_orders_price_id` ON `orders` (`price_id`);

CREATE INDEX `idx_orders_address_id` ON `orders` (`address_id`);

CREATE INDEX `idx_manufacturers_created_at` ON `manufacturers` (`created_at`);

CREATE INDEX `idx_manufacturers_name` ON `manufacturers` (`name`);

CREATE INDEX `idx_manufacturers_address_id` ON `manufacturers` (`address_id`);

CREATE INDEX `idx_brands_created_at` ON `brands` (`created_at`);

CREATE UNIQUE INDEX `idx_brands_name_email` ON `brands` (`name`, `email`);

CREATE INDEX `idx_brands_manufacturer_id` ON `brands` (`manufacturer_id`);

CREATE INDEX `idx_providers_created_at` ON `providers` (`created_at`);

CREATE INDEX `idx_providers_address_id` ON `providers` (`address_id`);

CREATE UNIQUE INDEX `idx_providers_name_email` ON `providers` (`name`, `email`);
