
----------------------------------------------------------------------------------------
### Volume total des ventes (Total Sales) 
USE toys_and_models;
create or replace view Total AS (
                              SELECT month(orderDate) AS mois, year(orderDate) AS ans, orderDate, productLine, productName, customerNumber, quantityOrdered, status, priceEach, comments, SUM(quantityOrdered*priceEach) AS CA_Total
                              FROM orders, orderdetails, products
                              WHERE (orders.orderNumber= orderdetails.orderNumber AND orderdetails.productCode=products.productCode) 
                              Group by mois, ans, orderDate, productLine, productName, customerNumber, quantityOrdered,status, priceEach, comments
                              );
SELECT *
 from Total;
create or replace view vendus_3 AS (
                              SELECT month(orderDate) AS mois, year(orderDate) AS ans, orderDate, productLine, productName, customerNumber, quantityOrdered, status, priceEach, SUM(quantityOrdered*priceEach) AS CA
                              FROM orders, orderdetails, products
                              WHERE (orders.orderNumber= orderdetails.orderNumber AND orderdetails.productCode=products.productCode) AND status = "Shipped" 
                              Group by mois, ans, orderDate, productLine, productName, customerNumber, quantityOrdered, priceEach
                              ); 

SELECT * from vendus_3 ;

-----------------------------------------------------------------------------------------
### Classement  customer, TOP 20% customer qui donne 80% profit
WITH customer_total AS 
(SELECT c.customerNumber, c.customerName, c.city, c.postalCode, c.country,
SUM(CASE WHEN YEAR(o.orderDate) = 2022 THEN od.quantityOrdered * od.priceEach ELSE 0 END) AS CA_2022, 
SUM(CASE WHEN YEAR(o.orderDate) = 2023 THEN od.quantityOrdered * od.priceEach ELSE 0 END) AS CA_2023,
SUM(CASE WHEN YEAR(o.orderDate) = 2024 THEN od.quantityOrdered * od.priceEach ELSE 0 END) AS CA_2024 
FROM customers AS c 
JOIN orders AS o USING (customerNumber)
JOIN orderdetails AS od USING (orderNumber) 
WHERE o.status = 'Shipped' 
GROUP BY c.customerNumber, c.customerName, c.city, c.postalCode, c.country)
SELECT customerNumber, customerName, city, postalCode, country, CA_2022, CA_2023, CA_2024, 
NTILE(5) OVER (ORDER BY CA_2022 DESC) AS group_customers_2022, 
NTILE(5) OVER (ORDER BY CA_2023 DESC) AS group_customers_2023, 
NTILE(5) OVER (ORDER BY CA_2024 DESC) AS group_customers_2024 
FROM customer_total
ORDER BY customerNumber;

----------------------------------------------------------------------------------------------
### TOP 5 produits par categorie, chaque année, par customer 
WITH top_prod_productline as (
SELECT productline, 
       year(orderDate),
       productname,
       SUM(quantityordered *priceeach) AS CA
       ,RANK() OVER( partition by  productline, year(orderDate) order by  SUM(quantityordered * priceeach) DESC) as TOP
FROM products 
INNER JOIN  orderdetails USING(productcode)
INNER JOIN  orders USING(orderNumber)
INNER JOIN  customers USING(customerNumber)
WHERE status = "Shipped" 
GROUP BY productline, year(orderDate), productname
ORDER BY TOP, CA desc)

SELECT *
FROM  top_prod_productline 
WHERE TOP <= 5 ;
