USE otusdb;

-- NOTE! same password is used just for the sake of simplicity

-- create 'client' user and grant him some rights
create user if not exists 'client'@'localhost' identified by '12345';
grant all privileges on otusdb.products to 'client'@'localhost';
grant all privileges on otusdb.provider_products to 'client'@'localhost';
grant all privileges on otusdb.prices to 'client'@'localhost';
grant all privileges on otusdb.categories to 'client'@'localhost';

-- create 'manager' user and grant him some rights
create user if not exists 'manager'@'localhost' identified by '12345';
grant all privileges on otusdb.products to 'manager'@'localhost';
grant all privileges on otusdb.prices to 'manager'@'localhost';
grant all privileges on otusdb.orders to 'manager'@'localhost';

drop procedure if exists get_products;
delimiter //

create
    definer = 'client'@'localhost'
    procedure get_products(
    IN category_id varchar(36),
    IN min_price numeric(15, 2), IN max_price numeric(15, 2),
    IN order_by_field varchar(255),
    IN page_limit int, IN page_offset int)
    sql security invoker
begin
    set @q=concat(
        'select
            bin_to_uuid(p.id) as id,
            p.name as name,
            pr.amount as price,
            bin_to_uuid(pp.provider_id) as provider_id
        from products as p
            inner join provider_products as pp on pp.product_id = p.id
            inner join prices as pr on pr.id = pp.price_id
        where p.category_id = ',
        concat('uuid_to_bin(\'', category_id, '\')'),
        ' and pr.amount between ', min_price, ' and ', max_price,
        ' order by ', order_by_field, ' limit ', page_limit, ' offset ', page_offset);
    prepare stmt1 FROM @q;
    execute stmt1;
    deallocate prepare stmt1;
end //

delimiter ;

drop procedure if exists get_orders;
delimiter //

create
    definer = 'manager'@'localhost'
    procedure get_orders(
    IN from_dt datetime,
    IN to_dt datetime,
    IN group_by_product bool,
    IN group_by_category bool,
    IN group_by_customer bool)
    sql security invoker
begin
    set @q=case
        when group_by_product then
            concat(
                'select
                    case grouping(o.product_id)
                    when 1 then \'summary\'
                    else
                    bin_to_uuid(o.product_id)
                    end as product_id,
                    count(1) as orders_count,
                    sum(pr.amount*o.quantity) as total
                from orders as o
                inner join prices as pr on pr.id = o.price_id
                inner join products as p on p.id = o.product_id
                where o.status = \'COMPLETED\' and o.created_at between \'', concat(from_dt), '\' and \'', concat(to_dt), '\' group by product_id with rollup'
            )
        when group_by_category then
            concat(
                    'select
                        case grouping(p.category_id)
                        when 1 then \'summary\'
                        else
                        bin_to_uuid(p.category_id)
                        end as category_id,
                        count(1) as orders_count,
                        sum(pr.amount*o.quantity) as total
                    from orders as o
                    inner join prices as pr on pr.id = o.price_id
                    inner join products as p on p.id = o.product_id
                    where o.status = \'COMPLETED\' and o.created_at between \'', concat(from_dt), '\' and \'', concat(to_dt), '\' group by category_id with rollup'
                )
        when group_by_customer then
            concat(
                    'select
                        case grouping(o.customer_id)
                        when 1 then \'summary\'
                        else
                        bin_to_uuid(o.customer_id)
                        end as customer_id,
                        count(1) as orders_count,
                        sum(pr.amount*o.quantity) as total
                    from orders as o
                    inner join prices as pr on pr.id = o.price_id
                    inner join products as p on p.id = o.product_id
                    where o.status = \'COMPLETED\' and o.created_at between \'', concat(from_dt), '\' and \'', concat(to_dt), '\' group by customer_id with rollup'
                )
    end;
    prepare stmt1 FROM @q;
    execute stmt1;
    deallocate prepare stmt1;
end //

delimiter ;

-- grant execute permissions
grant execute on procedure get_products TO 'client'@'localhost';
grant execute on procedure get_orders TO 'manager'@'localhost';
