USE otusdb;

create or replace view products_offers_view as select
    bin_to_uuid(p.id) as product_id,
    p.name as product_name,
    count(pr.id) as offers_count,
    max(pr.amount) as max,
    min(pr.amount) as min,
    avg(pr.amount) as avg
from products as p, provider_products as pp, prices as pr
where p.id = pp.product_id and pp.price_id = pr.id
group by product_id
having count(pr.id) >= 2;


create or replace view categories_overview as select
    case grouping(c.name)
    when 1 then 'Summary'
    else c.name
    end as category_name,
    count(1) as product_count
from products as p
    inner join categories as c on c.id = p.category_id
group by c.name
with rollup;

create or replace view categories_products_overview as select
    bin_to_uuid(c.id) as category_id,
    bin_to_uuid((
        select
            p.id
        from products as p
            inner join provider_products as pp on pp.product_id = p.id
            inner join prices as pr on pr.id = pp.price_id
        where c.id = p.category_id
        group by p.id
        order by max(pr.amount) DESC
        limit 1
        )) as most_exp,
    (
        select
            max(pr.amount)
        from products as p
            inner join provider_products as pp on pp.product_id = p.id
            inner join prices as pr on pr.id = pp.price_id
        where c.id = p.category_id
        group by p.id
        order by max(pr.amount) DESC
        limit 1
    ) as most_exp_price,
    bin_to_uuid((
        select
            p.id
        from products as p
            inner join provider_products as pp on pp.product_id = p.id
            inner join prices as pr on pr.id = pp.price_id
        where c.id = p.category_id
        group by p.id
        order by min(pr.amount)
        limit 1
    )) as most_cheap,
    (
        select
            min(pr.amount)
        from products as p
            inner join provider_products as pp on pp.product_id = p.id
            inner join prices as pr on pr.id = pp.price_id
        where c.id = p.category_id
        group by p.id
        order by min(pr.amount)
        limit 1
    ) as most_cheap_price
from categories as c
having most_exp is not null and most_cheap is not null;
