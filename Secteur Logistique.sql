--- comparer le ratio de stock 2023/2024
### stock 2023= stock 2024 + vente 2023
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

-------------------------------------------------------------------------------------
### Taux de livraison :

WITH no_shipped AS (
	SELECT COUNT(*)
    FROM orders 
    WHERE `status` != 'Shipped'  
    ),
  	shipped AS (
    SELECT SUM(shippedDate) 
    FROM orders 
    WHERE `status` = 'Shipped'
    ) 

SELECT orderNumber, 
	   orderDate,
       requiredDate, 
       shippedDate,
       `status`,  
       comments, 
       shippedDate-requiredDate AS delais, 
       sum(quantityOrdered*priceEach)
FROM orders
JOIN orderdetails USING (orderNumber)
WHERE `status` != 'Shipped'  
GROUP BY orderNumber, orderDate, shippedDate, `status`,  comments, delais;	


-- WHERE orderDate BETWEEN 2024-01-01 AND 2024-03-01;
SELECT * from orders;

-------------------------------------------------------------------------------------------------------
### CA par office par pays

WITH country_employee AS (
	SELECT lastname, firstname,officeCode, jobtitle, city, country, employeeNumber
    FROM employees
    INNER JOIN offices USING (officecode)
),
	ca_2023 AS (
	SELECT customerName, city, country,salesRepEmployeeNumber, sum(quantityOrdered*priceEach) AS ca
	FROM customers
	JOIN orders USING(customerNumber)
	JOIN orderdetails USING(orderNumber)
	GROUP BY  customerName, city, country,salesRepEmployeeNumber
	ORDER BY customerName
)

SELECT country_employee.lastname, country_employee.firstname, country_employee.officeCode, country_employee.jobtitle, country_employee.city, country_employee.country, 
 ca_2023.ca
FROM country_employee
INNER JOIN ca_2023 ON country_employee.employeeNumber=ca_2023.salesRepEmployeeNumber
ORDER BY ca DESC, country_employee.country;
