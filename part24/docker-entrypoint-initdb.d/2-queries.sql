-- using row_number
select row_number() over (order by id), id, first_name from customers;

-- using rank function
select rank() over (order by id), id, first_name from customers;

-- select min and max product price for each category
select distinct
    first_value(p.id) over (partition by category_id order by pr.amount desc) as max_product_id,
    c.id as category_id, max(pr.amount) over (partition by category_id) as max_product_price,
    first_value(p.id) over (partition by category_id order by pr.amount asc) as min_product_id,
    min(pr.amount) over (partition by category_id) as min_product_price
from categories as c
    inner join products as p on p.category_id = c.id
    inner join provider_products as pp on pp.product_id = p.id
    inner join prices as pr on pr.id = pp.price_id
order by category_id;

-- select amount of customers divided by genders for each year
select * from crosstab(
    'select
        gender, cast(extract(YEAR from created_at) as int) as created_year,
        count(*) as cnt
        from customers group by gender, created_year order by 1', $$VALUES('2019'::text), ('2020'::text)$$)
        AS (gender genders, "2019" text, "2020" text);


-- select customers divided by correspondence languages
select
       row_number() over (partition by correspondence_language order by first_name) as group_id,
       id,
       correspondence_language
from customers;
