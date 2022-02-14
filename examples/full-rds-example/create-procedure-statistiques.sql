CREATE OR REPLACE PROCEDURE FEED_STATS(ProductId INTEGER) LANGUAGE plpgsql AS $$
DECLARE

infos record;

BEGIN

-- retrieve the total amount for a specific product
for infos in (
select product.label as ProductLabel, sum(quantity * cost) as totalAmount
from customer,product,basket
where basket.customer_id = customer.id
and basket.product_id = product.id
and product.id = ProductId
group by product.label)
loop
    -- insert into stats table
    insert into stats (product,value) values (infos.ProductLabel,infos.totalAmount);
end loop;

END;
$$;
