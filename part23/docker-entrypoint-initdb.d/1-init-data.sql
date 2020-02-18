-- insert test countries
insert into countries (name) values ('Norway'), ('Sweden'), ('Denmark');

-- insert test regions
insert into regions (name, country_id)
values ('Norway_Region', (select id from countries where name = 'Norway')),
       ('Sweden_Region', (select id from countries where name = 'Sweden')),
       ('Denmark_Region', (select id from countries where name = 'Denmark'));

-- insert test cities
insert into cities (name, region_id)
values ('Norway_Region_City', (select id from regions where name = 'Norway_Region')),
       ('Sweden_Region_City', (select id from regions where name = 'Sweden_Region')),
       ('Denmark_Region_City', (select id from regions where name = 'Denmark_Region'));

-- insert test streets
insert into streets (name, city_id)
values ('Norway_Region_City_Street', (select id from cities where name = 'Norway_Region_City')),
       ('Sweden_Region_City_Street', (select id from cities where name = 'Sweden_Region_City')),
       ('Denmark_Region_City_Street', (select id from cities where name = 'Denmark_Region_City'));

-- insert test buildings
insert into buildings (number, litera, street_id)
values (1, 'A', (select id from streets where name = 'Norway_Region_City_Street')),
       (2, 'B', (select id from streets where name = 'Sweden_Region_City_Street')),
       (3, 'C', (select id from streets where name = 'Denmark_Region_City_Street'));

-- insert test addresses
insert into addresses (building_id, postal_code)
values (
           (select buildings.id
            from buildings
                     inner join streets on streets.id = buildings.street_id
            where streets.name = 'Norway_Region_City_Street'), '123'),
       (
           (select buildings.id
            from buildings
                     inner join streets on streets.id = buildings.street_id
            where streets.name = 'Sweden_Region_City_Street'), '456'),
       (
           (select buildings.id
            from buildings
                     inner join streets on streets.id = buildings.street_id
            where streets.name = 'Denmark_Region_City_Street'), '789'),
       (
           (select buildings.id
            from buildings
                     inner join streets on streets.id = buildings.street_id
            where streets.name = 'Norway_Region_City_Street'), '001'),
       (
           (select buildings.id
            from buildings
                     inner join streets on streets.id = buildings.street_id
            where streets.name = 'Sweden_Region_City_Street'), '002'),
       (
           (select buildings.id
            from buildings
                     inner join streets on streets.id = buildings.street_id
            where streets.name = 'Sweden_Region_City_Street'), '003'),
       (
           (select buildings.id
            from buildings
                     inner join streets on streets.id = buildings.street_id
            where streets.name = 'Sweden_Region_City_Street'), '004'),
       (
           (select buildings.id
            from buildings
                     inner join streets on streets.id = buildings.street_id
            where streets.name = 'Denmark_Region_City_Street'), '005'),
       (
           (select buildings.id
            from buildings
                     inner join streets on streets.id = buildings.street_id
            where streets.name = 'Norway_Region_City_Street'), '006');;


-- insert test customers
insert into customers (
    title,
    first_name,
    last_name,
    gender,
    birth_date,
    email,
    marital_status,
    correspondence_language)
values (
           'Mr',
           'Customer_A_First_Name',
           'Customer_A_Last_Name',
           'male',
           '1993-02-17',
           'test-a@gmail.com',
           'married',
           'EN'
       ),
       (
           'Ms',
           'Customer_B_First_Name',
           'Customer_B_Last_Name',
           'female',
           '1965-11-22',
           'test-b@gmail.com',
           'married',
           'EN'
       ),
       (
           'Miss',
           'Customer_C_First_Name',
           'Customer_C_Last_Name',
           'female',
           '1987-09-12',
           'test-c@gmail.com',
           'single',
           'FR'
       );

-- insert test customer_addresses
insert into customer_addresses (address_id, customer_id, is_default)
values (
           (select id from addresses where postal_code = '123'),
           (select id from customers where first_name = 'Customer_A_First_Name'),
           true
       ),
       (
           (select id from addresses where postal_code = '456'),
           (select id from customers where first_name = 'Customer_B_First_Name'),
           false
       ),
       (
           (select id from addresses where postal_code = '789'),
           (select id from customers where first_name = 'Customer_C_First_Name'),
           true
       );

-- insert test manifacturers
insert into manufacturers (name, email, contact_number, address_id)
values (
           'Manifacturer_A',
           'man-a@gmail.com',
           '+7999999992',
           (select id from addresses where postal_code = '001')
       ),
       (
           'Manifacturer_B',
           'man-b@gmail.com',
           '+7999999991',
           (select id from addresses where postal_code = '002')
       ),
       (
           'Manifacturer_C',
           'man-c@gmail.com',
           '+7999999990',
           (select id from addresses where postal_code = '003')
       );

-- insert test providers
insert into providers (name, email, contact_number, address_id)
values (
           'Provider_A',
           'provider-a@gmail.com',
           '+793311222333',
           (select id from addresses where postal_code = '004')
       ),
       (
           'Provider_B',
           'provider-b@gmail.com',
           '+79331122433',
           (select id from addresses where postal_code = '005')
       ),
       (
           'Provider_C',
           'provider-c@gmail.com',
           '+79331121123',
           (select id from addresses where postal_code = '006')
       );

-- insert test brands
insert into brands (name, email, contact_number, manufacturer_id)
values (
           'Brand_A',
           'brand-a@gmail.com',
           '+123123',
           (select id from manufacturers where name = 'Manifacturer_A')
       ),
       (
           'Brand_B',
           'brand-b@gmail.com',
           '+123123',
           (select id from manufacturers where name = 'Manifacturer_B')
       ),
       (
           'Brand_C',
           'brand-c@gmail.com',
           '+123123',
           (select id from manufacturers where name = 'Manifacturer_C')
       );

-- insert test root category
insert into categories (parent_id, name)
values (null, 'Root_Category');

-- insert test categories
insert into categories (parent_id, name)
values ((select id from categories where name = 'Root_Category'), 'Category_A'),
       ((select id from categories where name = 'Root_Category'), 'Category_B'),
       ((select id from categories where name = 'Root_Category'), 'Category_C');

-- insert test currency
insert into currencies (code, cbr_name, rate)
values ('dqw', 'wd', '222.3');

-- insert test prices
insert into prices (amount, currency_id)
values (3499.000, (select id from currencies limit 1)),
       (6599.000, (select id from currencies limit 1)),
       (1799.000, (select id from currencies limit 1)),
       (2490.800, (select id from currencies limit 1)),
       (5499.000, (select id from currencies limit 1)),
       (7499.000, (select id from currencies limit 1)),
       (6999.000, (select id from currencies limit 1)),
       (350.000, (select id from currencies limit 1)),
       (375.000, (select id from currencies limit 1));

-- insert test products
insert into products (name, category_id, brand_id, attributes)
VALUES  -- A category products
        ('Product A_1', (select id from categories where name = 'Category_A'),
         (select id from brands where name = 'Brand_A'),
         '{"screen": "16 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 2, "usb": 0}}'),
        ('Product A_2', (select id from categories where name = 'Category_A'),
         (select id from brands where name = 'Brand_A'),
         '{"screen": "16 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 2, "usb": 0}}'),
        ('Product A_3', (select id from categories where name = 'Category_A'),
         (select id from brands where name = 'Brand_A'),
         '{"screen": "16 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 2, "usb": 0}}'),
        -- B category products
        ('Product B_1', (select id from categories where name = 'Category_B'),
         (select id from brands where name = 'Brand_B'),
         '{"screen": "16 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 2, "usb": 0}}'),
        ('Product B_2', (select id from categories where name = 'Category_B'),
         (select id from brands where name = 'Brand_B'),
         '{"screen": "27 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 5, "usb": 1}}'),
        ('Product B_3', (select id from categories where name = 'Category_B'),
         (select id from brands where name = 'Brand_B'),
         '{"screen": "32 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 2, "usb": 0}}'),
        -- C category products
        ('Product C_1', (select id from categories where name = 'Category_C'),
         (select id from brands where name = 'Brand_C'),
         '{"screen": "16 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 2, "usb": 0}}'),
        ('Product C_2', (select id from categories where name = 'Category_C'),
         (select id from brands where name = 'Brand_C'),
         '{"screen": "27 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 5, "usb": 1}}'),
        ('Product C_3', (select id from categories where name = 'Category_C'),
         (select id from brands where name = 'Brand_C'),
         '{"screen": "32 inch", "resolution": "3072 x 1920 pixels", "ports": {"thunderbolt": 2, "usb": 0}}');

-- insert test provider products
insert into provider_products (product_id, provider_id, price_id)
values -- provider A products
       (
           (select id from products where name = 'Product A_1'),
           (select id from providers where name = 'Provider_A'),
           (select id from prices where amount = 3499.000 limit 1)
       ),
       (
           (select id from products where name = 'Product B_1'),
           (select id from providers where name = 'Provider_A'),
           (select id from prices where amount = 7499.000 limit 1)
       ),
       (
           (select id from products where name = 'Product C_1'),
           (select id from providers where name = 'Provider_A'),
           (select id from prices where amount = 375.000 limit 1)
       ),
       -- provider B products
       (
           (select id from products where name = 'Product A_1'),
           (select id from providers where name = 'Provider_B'),
           (select id from prices where amount = 2490.800 limit 1)
       ),
       (
           (select id from products where name = 'Product C_1'),
           (select id from providers where name = 'Provider_B'),
           (select id from prices where amount = 350.000 limit 1)
       ),
       (
           (select id from products where name = 'Product B_1'),
           (select id from providers where name = 'Provider_B'),
           (select id from prices where amount = 6599.000 limit 1)
       ),
       -- provider C products
       (
           (select id from products where name = 'Product C_1'),
           (select id from providers where name = 'Provider_C'),
           (select id from prices where amount = 1799.000 limit 1)
       ),
       (
           (select id from products where name = 'Product A_1'),
           (select id from providers where name = 'Provider_C'),
           (select id from prices where amount = 5499.000 limit 1)
       );

-- insert test orders
insert into orders (customer_id, product_id, price_id, address_id, quantity,status)
values (
           (select id from customers where first_name = 'Customer_A_First_Name'),
           (select id from products where name = 'Product A_1'),
           (select id from prices where amount = 2490.800),
           (select id from addresses where postal_code = '002'),
           5,
           'COMPLETED'
       ),
       (
           (select id from customers where first_name = 'Customer_A_First_Name'),
           (select id from products where name = 'Product B_1'),
           (select id from prices where amount = 6599.000),
           (select id from addresses where postal_code = '002'),
           3,
           'COMPLETED'
       ),
       (
           (select id from customers where first_name = 'Customer_A_First_Name'),
           (select id from products where name = 'Product C_1'),
           (select id from prices where amount = 1799.000),
           (select id from addresses where postal_code = '002'),
           2,
           'COMPLETED'
       ),
       (
           (select id from customers where first_name = 'Customer_B_First_Name'),
           (select id from products where name = 'Product A_1'),
           (select id from prices where amount = 1799.000),
           (select id from addresses where postal_code = '001'),
           2,
           'PROCESSING'
       ),
       (
           (select id from customers where first_name = 'Customer_C_First_Name'),
           (select id from products where name = 'Product C_1'),
           (select id from prices where amount = 375.000),
           (select id from addresses where postal_code = '003'),
           30,
           'ON_HOLD'
       ),
       (
           (select id from customers where first_name = 'Customer_C_First_Name'),
           (select id from products where name = 'Product B_1'),
           (select id from prices where amount = 3499.000),
           (select id from addresses where postal_code = '003'),
           17,
           'COMPLETED'
       );
