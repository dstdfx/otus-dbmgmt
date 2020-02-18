CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE "languages" AS ENUM ('RU', 'EN', 'IT', 'CS', 'DE', 'PL', 'FR', 'NL', 'HU');
CREATE TYPE "titles" AS ENUM ('Mr','Mrs','Ms','Miss');
CREATE TYPE "genders" AS ENUM ('male', 'female');
CREATE TYPE "marital_statuses" AS ENUM ('married', 'single', 'divorced', 'widowed');
CREATE TYPE "order_statuses"  AS ENUM ('ON_HOLD', 'PROCESSING', 'COMPLETED');
CREATE TYPE "action_types" AS ENUM('CHANGE_PERSONAL_INFO', 'CREATE_ORDER', 'CHANGE_ORDER', 'CANCEL_ORDER');

CREATE TABLE "customers" (
                             "id" uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                             "created_at" TIMESTAMP DEFAULT (now()),
                             "updated_at" TIMESTAMP,
                             "deleted_at" TIMESTAMP,
                             "title" "titles",
                             "first_name" VARCHAR(255) NOT NULL,
                             "last_name" VARCHAR(255) NOT NULL,
                             "gender" "genders",
                             "birth_date" TIMESTAMP,
                             "email" VARCHAR(255),
                             "marital_status" "marital_statuses",
                             "correspondence_language" "languages"
);

CREATE TABLE "customer_addresses"(
                                     "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                                     "created_at"  TIMESTAMP        DEFAULT (now()),
                                     "updated_at"  TIMESTAMP,
                                     "deleted_at"  TIMESTAMP,
                                     "address_id"  uuid NOT NULL,
                                     "customer_id" uuid NOT NULL,
                                     "is_default"  BOOL
);

CREATE TABLE "addresses" (
                             "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                             "created_at"  TIMESTAMP        DEFAULT (now()),
                             "updated_at"  TIMESTAMP,
                             "deleted_at"  TIMESTAMP,
                             "building_id" uuid NOT NULL,
                             "postal_code" VARCHAR(255)
);

CREATE TABLE "countries" (
                             "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                             "created_at"  TIMESTAMP        DEFAULT (now()),
                             "updated_at"  TIMESTAMP,
                             "deleted_at"  TIMESTAMP,
                             "name" VARCHAR(255) NOT NULL
);

CREATE TABLE "regions" (
                           "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                           "created_at"  TIMESTAMP        DEFAULT (now()),
                           "updated_at"  TIMESTAMP,
                           "deleted_at"  TIMESTAMP,
                           "name" VARCHAR(255) NOT NULL,
                           "country_id" uuid NOT NULL
);

CREATE TABLE "cities" (
                          "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                          "created_at"  TIMESTAMP        DEFAULT (now()),
                          "updated_at"  TIMESTAMP,
                          "deleted_at"  TIMESTAMP,
                          "name" VARCHAR(255) NOT NULL,
                          "region_id" uuid NOT NULL
);

CREATE TABLE "streets" (
                           "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                           "created_at"  TIMESTAMP        DEFAULT (now()),
                           "updated_at"  TIMESTAMP,
                           "deleted_at"  TIMESTAMP,
                           "name" VARCHAR(255) NOT NULL,
                           "city_id" uuid NOT NULL
);

CREATE TABLE "buildings" (
                             "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                             "created_at"  TIMESTAMP        DEFAULT (now()),
                             "updated_at"  TIMESTAMP,
                             "deleted_at"  TIMESTAMP,
                             "number" INT NOT NULL,
                             "litera" VARCHAR(2),
                             "street_id" uuid NOT NULL
);

CREATE TABLE "products" (
                            "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                            "created_at"  TIMESTAMP        DEFAULT (now()),
                            "updated_at"  TIMESTAMP,
                            "deleted_at"  TIMESTAMP,
                            "name" VARCHAR(255) NOT NULL,
                            "category_id" uuid NOT NULL,
                            "brand_id" uuid NOT NULL,
                            "attributes" JSONB NOT NULL
);

CREATE TABLE "provider_products" (
                                     "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                                     "created_at"  TIMESTAMP        DEFAULT (now()),
                                     "updated_at"  TIMESTAMP,
                                     "deleted_at"  TIMESTAMP,
                                     "product_id" uuid NOT NULL,
                                     "provider_id" uuid NOT NULL,
                                     "price_id" uuid NOT NULL
);

CREATE TABLE "prices" (
                          "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                          "created_at"  TIMESTAMP        DEFAULT (now()),
                          "updated_at"  TIMESTAMP,
                          "deleted_at"  TIMESTAMP,
                          "amount" NUMERIC(15, 2) NOT NULL,
                          "currency_id" uuid NOT NULL
);

CREATE TABLE "currencies" (
                              "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                              "created_at"  TIMESTAMP        DEFAULT (now()),
                              "updated_at"  TIMESTAMP,
                              "deleted_at"  TIMESTAMP,
                              "code" VARCHAR(255) NOT NULL,
                              "cbr_name" VARCHAR(255) NOT NULL,
                              "rate" VARCHAR(255) NOT NULL
);

CREATE TABLE "categories" (
                              "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                              "created_at"  TIMESTAMP        DEFAULT (now()),
                              "updated_at"  TIMESTAMP,
                              "deleted_at"  TIMESTAMP,
                              "parent_id" uuid,
                              "name" VARCHAR(255) NOT NULL
);

CREATE TABLE "orders" (
                          "id"          uuid DEFAULT (uuid_generate_v4()),
                          "created_at"  TIMESTAMP  DEFAULT (now()),
                          "updated_at"  TIMESTAMP,
                          "deleted_at"  TIMESTAMP,
                          "customer_id" uuid NOT NULL,
                          "product_id" uuid NOT NULL,
                          "price_id" uuid NOT NULL,
                          "address_id" uuid NOT NULL,
                          "quantity" INT NOT NULL CHECK ("quantity" > 0),
                          "status" "order_statuses" DEFAULT 'ON_HOLD',
                          PRIMARY KEY ("id", "created_at")
);

CREATE TABLE "manufacturers" (
                                 "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                                 "created_at"  TIMESTAMP        DEFAULT (now()),
                                 "updated_at"  TIMESTAMP,
                                 "deleted_at"  TIMESTAMP,
                                 "name" VARCHAR(255) NOT NULL,
                                 "email" VARCHAR(255) NOT NULL,
                                 "contact_number" VARCHAR(15) NOT NULL,
                                 "address_id" uuid NOT NULL
);

CREATE TABLE "brands" (
                          "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                          "created_at"  TIMESTAMP        DEFAULT (now()),
                          "updated_at"  TIMESTAMP,
                          "deleted_at"  TIMESTAMP,
                          "name" VARCHAR(255) NOT NULL,
                          "email" VARCHAR(255) NOT NULL,
                          "contact_number" VARCHAR(15) NOT NULL,
                          "manufacturer_id" uuid NOT NULL
);

CREATE TABLE "providers" (
                             "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                             "created_at"  TIMESTAMP        DEFAULT (now()),
                             "updated_at"  TIMESTAMP,
                             "deleted_at"  TIMESTAMP,
                             "name" VARCHAR(255) NOT NULL,
                             "email" VARCHAR(255) NOT NULL,
                             "contact_number" VARCHAR(15) NOT NULL,
                             "address_id" uuid NOT NULL
);

CREATE TABLE "log_actions" (
                               "id"          uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
                               "created_at"  TIMESTAMP        DEFAULT (now()),
                               "customer_id" uuid NOT NULL,
                               "operation" "action_types" NOT NULL,
                               "description" VARCHAR(255) NOT NULL
);

ALTER TABLE "customer_addresses" ADD FOREIGN KEY ("address_id") REFERENCES "addresses" ("id");

ALTER TABLE "customer_addresses" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("id");

ALTER TABLE "addresses" ADD FOREIGN KEY ("building_id") REFERENCES "buildings" ("id");

ALTER TABLE "regions" ADD FOREIGN KEY ("country_id") REFERENCES "countries" ("id");

ALTER TABLE "cities" ADD FOREIGN KEY ("region_id") REFERENCES "regions" ("id");

ALTER TABLE "streets" ADD FOREIGN KEY ("city_id") REFERENCES "cities" ("id");

ALTER TABLE "buildings" ADD FOREIGN KEY ("street_id") REFERENCES "streets" ("id");

ALTER TABLE "products" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id");

ALTER TABLE "products" ADD FOREIGN KEY ("brand_id") REFERENCES "brands" ("id");

ALTER TABLE "provider_products" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("id");

ALTER TABLE "provider_products" ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id");

ALTER TABLE "provider_products" ADD FOREIGN KEY ("price_id") REFERENCES "prices" ("id");

ALTER TABLE "prices" ADD FOREIGN KEY ("currency_id") REFERENCES "currencies" ("id");

ALTER TABLE "categories" ADD FOREIGN KEY ("parent_id") REFERENCES "categories" ("id");

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("id");

ALTER TABLE "orders" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("id");

ALTER TABLE "orders" ADD FOREIGN KEY ("price_id") REFERENCES "prices" ("id");

ALTER TABLE "orders" ADD FOREIGN KEY ("address_id") REFERENCES "addresses" ("id");

ALTER TABLE "manufacturers" ADD FOREIGN KEY ("address_id") REFERENCES "addresses" ("id");

ALTER TABLE "brands" ADD FOREIGN KEY ("manufacturer_id") REFERENCES "manufacturers" ("id");

ALTER TABLE "providers" ADD FOREIGN KEY ("address_id") REFERENCES "addresses" ("id");

CREATE INDEX "idx_customers_created_at" ON "customers" ("created_at");

CREATE UNIQUE INDEX "idx_customers_email" ON "customers" ("email");

CREATE INDEX "idx_customer_addresses_created_at" ON "customer_addresses" ("created_at");

CREATE UNIQUE INDEX "idx_customer_addresses_address_id_customer_id" ON "customer_addresses" ("address_id", "customer_id");

CREATE INDEX "idx_addresses_building_id" ON "addresses" ("building_id");

CREATE INDEX "idx_addresses_postal_code" ON "addresses" ("postal_code");

CREATE INDEX "idx_regions_country_id" ON "regions" ("country_id");

CREATE INDEX "idx_cities_region_id" ON "cities" ("region_id");

CREATE INDEX "idx_streets_city_id" ON "streets" ("city_id");

CREATE INDEX "idx_buildings_street_id" ON "buildings" ("street_id");

CREATE INDEX "idx_products_created_at" ON "products" ("created_at");

CREATE INDEX "idx_products_category_id" ON "products" ("category_id");

CREATE INDEX "idx_products_brand_id" ON "products" ("brand_id");

CREATE INDEX "idx_provider_products_created_at" ON "provider_products" ("created_at");

CREATE UNIQUE INDEX "idx_provider_products_product_id_provider_id" ON "provider_products" ("product_id", "provider_id");

CREATE INDEX "idx_provider_products_price_id" ON "provider_products" ("price_id");

CREATE INDEX "idx_prices_currency_id" ON "prices" ("currency_id");

CREATE INDEX "idx_categories_name" ON "categories" ("name");

CREATE INDEX "idx_categories_parent_id" ON "categories" ("parent_id");

CREATE INDEX "idx_orders_created_at" ON "orders" ("created_at");

CREATE INDEX "idx_orders_customer_id_product_id" ON "orders" ("customer_id", "product_id");

CREATE INDEX "idx_orders_price_id" ON "orders" ("price_id");

CREATE INDEX "idx_orders_address_id" ON "orders" ("address_id");

CREATE INDEX "idx_manufacturers_created_at" ON "manufacturers" ("created_at");

CREATE INDEX "idx_manufacturers_name" ON "manufacturers" ("name");

CREATE INDEX "idx_manufacturers_address_id" ON "manufacturers" ("address_id");

CREATE INDEX "idx_brands_created_at" ON "brands" ("created_at");

CREATE UNIQUE INDEX "idx_brands_name_email" ON "brands" ("name", "email");

CREATE INDEX "idx_brands_manufacturer_id" ON "brands" ("manufacturer_id");

CREATE INDEX "idx_providers_created_at" ON "providers" ("created_at");

CREATE INDEX "idx_providers_address_id" ON "providers" ("address_id");

CREATE UNIQUE INDEX "idx_providers_name_email" ON "providers" ("name", "email");
