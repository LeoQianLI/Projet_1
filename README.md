# Projet_1
## KPI Logistique

1.Taux de livraison :

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
