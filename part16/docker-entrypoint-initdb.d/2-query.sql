USE otusdb;

select
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
