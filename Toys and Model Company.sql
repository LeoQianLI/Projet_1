-- comparer le ratio de stock 2023/2024
-- stock 2023= stock 2024 + vente 2023
select date(now()) - interval 1 year;
USE toys_and_models;
WITH stock2023 AS (
		SELECT  productName,
				quantityInstock AS stock_act,
                round(quantityinstock * 365 / sum(quantityOrdered) ) as ratio_stock,
				sum(CASE 
                       when year(orderDate) = 2023 then quantityOrdered
                       else 0
                       end) as total_ordered_each_product2023
                
		FROM products 
		LEFT JOIN orderdetails USING(productcode)
        LEFT JOIN orders USING (orderNumber)
        -- WHERE orderDate BETWEEN '2023-01-01' AND '2024-01-01'
        GROUP BY productName,quantityInstock
      ),
      Inventory_value AS (
	SELECT productName,quantityInstock*buyprice AS value_stock
	FROM products
    )
SELECT 
    stock2023.*, 
    Inventory_value.value_stock 
FROM stock2023
JOIN Inventory_value USING (productName)

order by ratio_stock;

SELECT SUM(quantityInStock * buyPrice) AS stock 
FROM products;

SELECT sum(quantityInstock) FROM products;

-- WHERE orderDate BETWEEN 2024-01-01 AND 2024-03-01;
SELECT * from orders;
order by ratio_stock;

SELECT SUM(quantityInStock * buyPrice) AS stock 
FROM products;

SELECT sum(quantityInstock) FROM products;

-- WHERE orderDate BETWEEN 2024-01-01 AND 2024-03-01;
SELECT * from orders;

