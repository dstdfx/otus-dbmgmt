USE otusdb;

SET @NORWAY_ID := UUID_TO_BIN(UUID()),
    @SWEDEN_ID := UUID_TO_BIN(UUID()),
    @DENMARK_ID := UUID_TO_BIN(UUID());


INSERT INTO countries (id, name)
VALUES (@NORWAY_ID, 'Norway'),
       (@SWEDEN_ID, 'Sweden'),
       (@DENMARK_ID, 'Denmark');

SET @AUSTLANDET_REGION_ID := UUID_TO_BIN(UUID()),
    @UPPLAND_REGION_ID := UUID_TO_BIN(UUID()),
    @HOVEDSTADEN := UUID_TO_BIN(UUID());

INSERT INTO regions (id, name, country_id)
VALUES (@AUSTLANDET_REGION_ID, 'Austlandet', @NORWAY_ID),
       (@UPPLAND_REGION_ID, 'Uppland', @SWEDEN_ID),
       (@HOVEDSTADEN,'Hovedstaden', @DENMARK_ID);

SET @OSLO_ID := UUID_TO_BIN(UUID()),
    @STOCKHOLM_ID := UUID_TO_BIN(UUID()),
    @COPENHAGEN_ID := UUID_TO_BIN(UUID());

INSERT INTO cities (id, name, region_id)
VALUES (@OSLO_ID, 'Oslo', @AUSTLANDET_REGION_ID),
       (@STOCKHOLM_ID, 'Stockholm', @UPPLAND_REGION_ID),
       (@COPENHAGEN_ID, 'Copenhagen', @HOVEDSTADEN);

SET @OSLO_STREET_ID := UUID_TO_BIN(UUID()),
    @STOCKHOLM_STREET_ID := UUID_TO_BIN(UUID()),
    @COPENHAGEN_STREET_ID := UUID_TO_BIN(UUID());

INSERT INTO streets (id, name, city_id)
VALUES (@OSLO_STREET_ID, 'Torggata', @OSLO_ID),
       (@STOCKHOLM_STREET_ID, 'Torggata', @STOCKHOLM_ID),
       (@COPENHAGEN_STREET_ID, 'Torggata', @COPENHAGEN_ID);

SET @BUILDING_ID_A := UUID_TO_BIN(UUID()),
    @BUILDING_ID_B := UUID_TO_BIN(UUID()),
    @BUILDING_ID_C := UUID_TO_BIN(UUID());

INSERT INTO buildings (id, number, litera, street_id)
VALUES (@BUILDING_ID_A, '1', 'A', @OSLO_STREET_ID),
       (@BUILDING_ID_B, '2', 'B', @STOCKHOLM_STREET_ID),
       (@BUILDING_ID_C, '3', 'C', @COPENHAGEN_STREET_ID);

SET @ADDRESS_ID_A := UUID_TO_BIN(UUID()),
    @ADDRESS_ID_B := UUID_TO_BIN(UUID()),
    @ADDRESS_ID_C := UUID_TO_BIN(UUID());

INSERT INTO addresses (id, building_id, postal_code)
VALUES (@ADDRESS_ID_A, @BUILDING_ID_A, '123123'),
       (@ADDRESS_ID_B, @BUILDING_ID_B, '123123'),
       (@ADDRESS_ID_C, @BUILDING_ID_C, '123123');

SET @CUSTOMER_ID_A := UUID_TO_BIN(UUID()),
    @CUSTOMER_ID_B := UUID_TO_BIN(UUID()),
    @CUSTOMER_ID_C := UUID_TO_BIN(UUID()),
    @CUSTOMER_ID_D := UUID_TO_BIN(UUID()),
    @CUSTOMER_ID_E := UUID_TO_BIN(UUID());


INSERT INTO customers (id, title, first_name, last_name, gender, birth_date, email, marital_status, correspondence_language)
VALUES (@CUSTOMER_ID_A, 'Mr', 'Customer A', 'Customer A', 'male', CURRENT_DATE, 'example_a@gmail.com', 'single', 'RU'),
       (@CUSTOMER_ID_B, 'Mrs', 'Customer B', 'Customer B', 'male', CURRENT_DATE, 'example_b@gmail.com', 'single', 'IT'),
       (@CUSTOMER_ID_C, 'Ms', 'Customer C', 'Customer C', 'female', CURRENT_DATE, 'example_c@gmail.com', 'single', 'RU'),
       (@CUSTOMER_ID_D, 'Ms', 'Customer D', 'Customer D', 'female', CURRENT_DATE, 'example_d@gmail.com', 'married', 'FR'),
       (@CUSTOMER_ID_E, 'Ms', 'Customer E', 'Customer E', 'female', CURRENT_DATE, 'example_e@gmail.com', 'married', 'IT');

INSERT INTO customer_addresses (id, address_id, customer_id, is_default)
VALUES (UUID_TO_BIN(UUID()), @ADDRESS_ID_A, @CUSTOMER_ID_A, true),
       (UUID_TO_BIN(UUID()), @ADDRESS_ID_B, @CUSTOMER_ID_B, true),
       (UUID_TO_BIN(UUID()), @ADDRESS_ID_C, @CUSTOMER_ID_C, true);

SET @MANUFACTURER_ID_A := UUID_TO_BIN(UUID()),
    @MANUFACTURER_ID_B := UUID_TO_BIN(UUID()),
    @MANUFACTURER_ID_C := UUID_TO_BIN(UUID());

INSERT INTO manufacturers (id, name, email, contact_number, address_id)
VALUES (@MANUFACTURER_ID_A, 'Manifacturer A', 'example_a@gmail.com', '+123123', @ADDRESS_ID_A),
       (@MANUFACTURER_ID_B, 'Manifacturer B', 'example_b@gmail.com', '+123123', @ADDRESS_ID_B),
       (@MANUFACTURER_ID_C, 'Manifacturer C', 'example_c@gmail.com', '+123123', @ADDRESS_ID_C);

SET @PROVIDER_ID_A := UUID_TO_BIN(UUID()),
    @PROVIDER_ID_B := UUID_TO_BIN(UUID()),
    @PROVIDER_ID_C := UUID_TO_BIN(UUID());

INSERT INTO providers (id, name, email, contact_number, address_id)
VALUES (@PROVIDER_ID_A, 'Provider A', 'example_a@gmail.com', '+123123', @ADDRESS_ID_A),
       (@PROVIDER_ID_B, 'Provider B', 'example_b@gmail.com', '+123123', @ADDRESS_ID_B),
       (@PROVIDER_ID_C, 'Provider C', 'example_c@gmail.com', '+123123', @ADDRESS_ID_C);

SET @BRAND_ID_A := UUID_TO_BIN(UUID()),
    @BRAND_ID_B := UUID_TO_BIN(UUID()),
    @BRAND_ID_C := UUID_TO_BIN(UUID());

INSERT INTO brands (id, name, email, contact_number, manufacturer_id)
VALUES (@BRAND_ID_A, 'Brand A', 'example_a@gmail.com', '+123123', @MANUFACTURER_ID_A),
       (@BRAND_ID_B, 'Brand B', 'example_b@gmail.com', '+123123', @MANUFACTURER_ID_B),
       (@BRAND_ID_C, 'Brand C', 'example_c@gmail.com', '+123123', @MANUFACTURER_ID_C);


SET @ROOT_CATEGORY_ID := UUID_TO_BIN(UUID()),
    @CATEGORY_ID_A := UUID_TO_BIN(UUID()),
    @CATEGORY_ID_B := UUID_TO_BIN(UUID()),
    @CATEGORY_ID_C := UUID_TO_BIN(UUID());

INSERT INTO categories (id, parent_id, name)
VALUES (@ROOT_CATEGORY_ID, NULL, 'Root category'),
       (@CATEGORY_ID_A, NULL, 'Category A'),
       (@CATEGORY_ID_B, NULL, 'Category B'),
       (@CATEGORY_ID_C, NULL, 'Category C');

SET @CURRENCY_ID := UUID_TO_BIN(UUID());
INSERT INTO currencies (id, code, cbr_name, rate)
VALUES (@CURRENCY_ID, 'dqw', 'wd', '222.3');

SET @PRICE_ID_A := UUID_TO_BIN(UUID()),
    @PRICE_ID_B := UUID_TO_BIN(UUID()),
    @PRICE_ID_C := UUID_TO_BIN(UUID());

INSERT INTO prices (id, amount, currency_id)
VALUES (@PRICE_ID_A, 2.500, @CURRENCY_ID),
       (@PRICE_ID_B, 3.700, @CURRENCY_ID),
       (@PRICE_ID_C, 11.000, @CURRENCY_ID);

SET @PRODUCT_ID_A := UUID_TO_BIN(UUID()),
    @PRODUCT_ID_B := UUID_TO_BIN(UUID()),
    @PRODUCT_ID_C := UUID_TO_BIN(UUID());

INSERT INTO products (id, name, category_id, brand_id, provider_id, attributes)
VALUES (@PRODUCT_ID_A, 'Product A', @CATEGORY_ID_A, @BRAND_ID_A, @PROVIDER_ID_A,
        '{"screen": "16 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 2, "usb": 0}}'),
       (@PRODUCT_ID_B, 'Product B', @CATEGORY_ID_B, @BRAND_ID_B, @PROVIDER_ID_B,
        '{"screen": "15 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 3, "usb": 0}}'),
       (@PRODUCT_ID_C, 'Product C', @CATEGORY_ID_C, @BRAND_ID_C, @PROVIDER_ID_C,
        '{"screen": "12 inch", "resolution": "1440 x 820 pixels", "ports": {"thunderbolt": 0, "usb": 3}}');

INSERT INTO provider_products (id, product_id, provider_id, price_id)
VALUES (UUID_TO_BIN(UUID()), @PRODUCT_ID_A, @PROVIDER_ID_A, @PRICE_ID_A),
       (UUID_TO_BIN(UUID()), @PRODUCT_ID_B, @PROVIDER_ID_B, @PRICE_ID_B),
       (UUID_TO_BIN(UUID()), @PRODUCT_ID_C, @PROVIDER_ID_C, @PRICE_ID_C);

INSERT INTO orders (id, customer_id, product_id, price_id, address_id, quantity, status)
VALUES (UUID_TO_BIN(UUID()), @CUSTOMER_ID_A, @PRODUCT_ID_A, @PRICE_ID_A, @ADDRESS_ID_A, 5, 'COMPLETED'),
       (UUID_TO_BIN(UUID()), @CUSTOMER_ID_A, @PRODUCT_ID_B, @PRICE_ID_B, @ADDRESS_ID_A, 3, 'COMPLETED'),
       (UUID_TO_BIN(UUID()), @CUSTOMER_ID_A, @PRODUCT_ID_C, @PRICE_ID_C, @ADDRESS_ID_A, 2, 'COMPLETED'),
       (UUID_TO_BIN(UUID()), @CUSTOMER_ID_B, @PRODUCT_ID_C, @PRICE_ID_C, @ADDRESS_ID_B, 2, 'PROCESSING'),
       (UUID_TO_BIN(UUID()), @CUSTOMER_ID_C, @PRODUCT_ID_B, @PRICE_ID_B, @ADDRESS_ID_C, 1, 'COMPLETED'),
       (UUID_TO_BIN(UUID()), @CUSTOMER_ID_A, @PRODUCT_ID_A, @PRICE_ID_A, @ADDRESS_ID_A, 5, 'ON_HOLD'),
       (UUID_TO_BIN(UUID()), @CUSTOMER_ID_A, @PRODUCT_ID_B, @PRICE_ID_B, @ADDRESS_ID_A, 3, 'ON_HOLD'),
       (UUID_TO_BIN(UUID()), @CUSTOMER_ID_A, @PRODUCT_ID_B, @PRICE_ID_B, @ADDRESS_ID_A, 9, 'PROCESSING');
