CREATE OR REPLACE PROCEDURE FEED_STATS(CustomerId INTEGER) LANGUAGE plpgsql AS $$
DECLARE

infos record;

BEGIN

-- retrieve the total Amount of customer's basket
for infos in (
select firstName ||' ' ||lastName as CustomerName, sum(quantity * cost) as totalAmount
from customer,product,basket
where basket.customer_id = customer.id
and basket.product_id = product.id
and customer.id = CustomerId
group by firstName ||' ' ||lastName)
loop
    -- insert into stats table
    insert into stats (domain,value) values (infos.CustomerName,infos.totalAmount);
end loop;

END;
$$;