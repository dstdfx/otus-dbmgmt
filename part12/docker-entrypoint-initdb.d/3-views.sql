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
    COUNT(1) as product_count
from products as p
    inner join categories as c on c.id = p.category_id
GROUP BY c.name
WITH ROLLUP;

