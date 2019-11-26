CREATE TYPE "title" AS ENUM (
  'Mr',
  'Mrs',
  'Ms',
  'Miss',
  'Frau'
);

CREATE TYPE "language" AS ENUM (
  'RU',
  'EN',
  'IT',
  'CS',
  'DE',
  'PL',
  'FR',
  'NL',
  'HU'
);

CREATE TYPE "gender" AS ENUM (
  'male',
  'female'
);

CREATE TYPE "martial_status" AS ENUM (
  'married',
  'single',
  'divorced',
  'widowed'
);

CREATE TYPE "order_status" AS ENUM (
  'ON_HOLD',
  'PROCESSING',
  'COMPLETED'
);

CREATE TABLE "customers" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "title" titles,
  "first_name" varchar(255) NOT NULL,
  "last_name" varchar(255) NOT NULL,
  "gender" gender NOT NULL,
  "birth_date" timestamp NOT NULL,
  "email" varchar(255) UNIQUE NOT NULL,
  "marital_status" martial_statuse,
  "correspondence_language" language
);

CREATE TABLE "customer_addresses" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "address_id" uuid NOT NULL,
  "customer_id" uuid NOT NULL,
  "is_default" bool
);

CREATE TABLE "addresses" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "building_id" uuid NOT NULL,
  "postal_code" varchar(255)
);

CREATE TABLE "countries" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "name" varchar(255) NOT NULL
);

CREATE TABLE "regions" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "name" varchar(255) NOT NULL,
  "country_id" uuid NOT NULL
);

CREATE TABLE "cities" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "name" varchar(255) NOT NULL,
  "region_id" uuid NOT NULL
);

CREATE TABLE "streets" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "name" varchar(255) NOT NULL,
  "city_id" uuid NOT NULL
);

CREATE TABLE "buildings" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "number" int NOT NULL,
  "litera" varchar(2),
  "street_id" uuid NOT NULL
);

CREATE TABLE "products" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "name" varchar(255) NOT NULL,
  "category_id" uuid NOT NULL,
  "brand_id" uuid NOT NULL,
  "provider_id" uuid NOT NULL
);

CREATE TABLE "provider_products" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "product_id" uuid NOT NULL,
  "provider_id" uuid NOT NULL,
  "price_id" uuid NOT NULL
);

CREATE TABLE "prices" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "amount" "numeric(15, 2)" NOT NULL,
  "currency_id" uuid NOT NULL
);

CREATE TABLE "currencies" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "code" varchar(255) NOT NULL,
  "cbr_name" varchar(255) NOT NULL,
  "rate" varchar(255) NOT NULL
);

CREATE TABLE "categories" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp,
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "parent_id" uuid,
  "name" varchar(255) NOT NULL
);

CREATE TABLE "orders" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "customer_id" uuid NOT NULL,
  "product_id" uuid NOT NULL,
  "price_id" uuid NOT NULL,
  "address_id" uuid NOT NULL,
  "quantity" uint NOT NULL,
  "status" order_status DEFAULT 'ON_HOLD'
);

CREATE TABLE "manufacturers" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "name" varchar(255) NOT NULL,
  "email" varchar(255) NOT NULL,
  "contact_number" varchar(15) NOT NULL,
  "address_id" uuid NOT NULL
);

CREATE TABLE "brands" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "name" varchar(255) NOT NULL,
  "email" varchar(255) NOT NULL,
  "contact_number" varchar(15) NOT NULL,
  "manufacturer_id" uuid NOT NULL
);

CREATE TABLE "providers" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "deleted_at" timestamp,
  "name" varchar(255) NOT NULL,
  "email" varchar(255) NOT NULL,
  "contact_number" varchar(15) NOT NULL,
  "address_id" uuid NOT NULL
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

ALTER TABLE "products" ADD FOREIGN KEY ("provider_id") REFERENCES "providers" ("id");

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

CREATE INDEX ON "customers" ("created_at");

CREATE UNIQUE INDEX ON "customers" ("email");

CREATE INDEX ON "customer_addresses" ("created_at");

CREATE UNIQUE INDEX ON "customer_addresses" ("address_id", "customer_id");

CREATE INDEX ON "addresses" ("building_id");

CREATE INDEX ON "addresses" ("postal_code");

CREATE INDEX ON "regions" ("country_id");

CREATE INDEX ON "cities" ("region_id");

CREATE INDEX ON "streets" ("city_id");

CREATE INDEX ON "buildings" ("street_id");

CREATE INDEX ON "products" ("created_at");

CREATE INDEX ON "products" ("category_id");

CREATE INDEX ON "products" ("brand_id");

CREATE INDEX ON "products" ("provider_id");

CREATE INDEX ON "provider_products" ("created_at");

CREATE UNIQUE INDEX ON "provider_products" ("product_id", "provider_id");

CREATE INDEX ON "provider_products" ("price_id");

CREATE INDEX ON "prices" ("currency_id");

CREATE INDEX ON "categories" ("name");

CREATE INDEX ON "categories" ("parent_id");

CREATE INDEX ON "orders" ("created_at");

CREATE UNIQUE INDEX ON "orders" ("customer_id", "product_id");

CREATE INDEX ON "orders" ("price_id");

CREATE INDEX ON "orders" ("address_id");

CREATE INDEX ON "manufacturers" ("created_at");

CREATE INDEX ON "manufacturers" ("name");

CREATE INDEX ON "manufacturers" ("address_id");

CREATE INDEX ON "brands" ("created_at");

CREATE UNIQUE INDEX ON "brands" ("name", "email");

CREATE INDEX ON "brands" ("manufacturer_id");

CREATE INDEX ON "providers" ("created_at");

CREATE INDEX ON "providers" ("address_id");

CREATE UNIQUE INDEX ON "providers" ("name", "email");

COMMENT ON COLUMN "customers"."id" IS 'unique identifier of the customer';

COMMENT ON COLUMN "customers"."title" IS 'customer titile, used in emails';

COMMENT ON COLUMN "customers"."first_name" IS 'customer first name';

COMMENT ON COLUMN "customers"."last_name" IS 'customer second name';

COMMENT ON COLUMN "customers"."gender" IS 'customer gender';

COMMENT ON COLUMN "customers"."birth_date" IS 'customer date of birth';

COMMENT ON COLUMN "customers"."email" IS 'customer email address';

COMMENT ON COLUMN "customers"."marital_status" IS 'customer matrial status';

COMMENT ON COLUMN "customers"."correspondence_language" IS 'language that is used in emails';

COMMENT ON COLUMN "customer_addresses"."id" IS 'unique identifier of the customer address';

COMMENT ON COLUMN "customer_addresses"."address_id" IS 'fk to customer address';

COMMENT ON COLUMN "customer_addresses"."customer_id" IS 'fk to customer';

COMMENT ON COLUMN "customer_addresses"."is_default" IS 'if true - address will be passed to all orders by default';

COMMENT ON COLUMN "addresses"."id" IS 'unique identifier of the address';

COMMENT ON COLUMN "addresses"."building_id" IS 'building info of the address';

COMMENT ON COLUMN "addresses"."postal_code" IS 'postal code of the address';

COMMENT ON COLUMN "countries"."id" IS 'unique identifier of the country';

COMMENT ON COLUMN "countries"."name" IS 'official name of the country';

COMMENT ON COLUMN "regions"."id" IS 'unique identifier of the region';

COMMENT ON COLUMN "regions"."name" IS 'name of the region';

COMMENT ON COLUMN "regions"."country_id" IS 'country where the region is located';

COMMENT ON COLUMN "cities"."id" IS 'unique identifier of the city';

COMMENT ON COLUMN "cities"."name" IS 'name of the city';

COMMENT ON COLUMN "streets"."id" IS 'unique identifier of the street';

COMMENT ON COLUMN "streets"."name" IS 'name of the street';

COMMENT ON COLUMN "streets"."city_id" IS 'city where the street is located';

COMMENT ON COLUMN "buildings"."id" IS 'unique identifier of the building';

COMMENT ON COLUMN "buildings"."number" IS 'number of the building';

COMMENT ON COLUMN "buildings"."litera" IS 'litera of the building';

COMMENT ON COLUMN "buildings"."street_id" IS 'street where the building is located';

COMMENT ON COLUMN "products"."id" IS 'unique identifier of the product';

COMMENT ON COLUMN "products"."name" IS 'name of the product';

COMMENT ON COLUMN "products"."category_id" IS 'category of the product';

COMMENT ON COLUMN "products"."brand_id" IS 'brand of the product';

COMMENT ON COLUMN "products"."provider_id" IS 'provider of the product';

COMMENT ON COLUMN "provider_products"."id" IS 'unique identifier of the provider product';

COMMENT ON COLUMN "provider_products"."product_id" IS 'providers product';

COMMENT ON COLUMN "provider_products"."provider_id" IS 'products provider';

COMMENT ON COLUMN "provider_products"."price_id" IS 'providers price for the product';

COMMENT ON COLUMN "prices"."id" IS 'unique identifier of the price';

COMMENT ON COLUMN "prices"."amount" IS 'amount of the price';

COMMENT ON COLUMN "prices"."currency_id" IS 'currency of the price';

COMMENT ON COLUMN "currencies"."id" IS 'unique identifier of the currency';

COMMENT ON COLUMN "currencies"."code" IS 'code of the currency';

COMMENT ON COLUMN "currencies"."cbr_name" IS 'central bank of the currency';

COMMENT ON COLUMN "currencies"."rate" IS 'rate of the currency';

COMMENT ON COLUMN "categories"."id" IS 'unique identifier of the category';

COMMENT ON COLUMN "categories"."parent_id" IS 'parent category';

COMMENT ON COLUMN "categories"."name" IS 'category name';

COMMENT ON COLUMN "orders"."id" IS 'unique identifier of the order';

COMMENT ON COLUMN "orders"."customer_id" IS 'customer which makes the order';

COMMENT ON COLUMN "orders"."product_id" IS 'product in the order';

COMMENT ON COLUMN "orders"."price_id" IS 'price for which one item of the product was purchased';

COMMENT ON COLUMN "orders"."address_id" IS 'order address';

COMMENT ON COLUMN "orders"."quantity" IS 'quantity of a product in the order';

COMMENT ON COLUMN "orders"."status" IS 'status of the order';

COMMENT ON COLUMN "manufacturers"."id" IS 'unique identifier of the manufacturer';

COMMENT ON COLUMN "manufacturers"."name" IS 'manufacturer name';

COMMENT ON COLUMN "manufacturers"."email" IS 'manufacturer email';

COMMENT ON COLUMN "manufacturers"."contact_number" IS 'manifacturer contact number';

COMMENT ON COLUMN "manufacturers"."address_id" IS 'address of the manifacturer';

COMMENT ON COLUMN "brands"."id" IS 'unique identifier of the brand';

COMMENT ON COLUMN "brands"."name" IS 'brand name';

COMMENT ON COLUMN "brands"."email" IS 'brand contact email';

COMMENT ON COLUMN "brands"."contact_number" IS 'brand contant number';

COMMENT ON COLUMN "brands"."manufacturer_id" IS 'manifacturer of the brand';

COMMENT ON COLUMN "providers"."id" IS 'unique identifier of the provider';

COMMENT ON COLUMN "providers"."name" IS 'provider name';

COMMENT ON COLUMN "providers"."email" IS 'provider contact email';

COMMENT ON COLUMN "providers"."contact_number" IS 'provider contanc number';

COMMENT ON COLUMN "providers"."address_id" IS 'address of the provider';
