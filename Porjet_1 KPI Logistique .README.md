# Projet_1 SQL & BI - Toys🪀 & Models🧸

Nous avons réalisé ce projet pour permettre à la direction de suivre les performances de l’entreprise dans quatre domaines clés : ventes, finances, logistique et ressources humaines. Les principaux KPI incluent l’analyse du chiffre d’affaires (par employé, région et produit), les marges brutes, les tendances des ventes, la fidélité des clients, la gestion des stocks, les délais de livraison et le recouvrement des créances. En cas d’impossibilité technique pour certains indicateurs, des alternatives créatives et adaptées aux besoins métiers ont été proposées

Des codes et captures d’écran détaillant chaque étape du projet sont également inclus.

## KPI Logistique

1.Taux de livraison :
![image](https://github.com/user-attachments/assets/bbd7c646-dd04-4ad4-a62a-26f066fa980c)

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
GROUP BY orderNumber, orderDate,
 shippedDate, `status`,  comments, delais;	

![图片1](https://github.com/user-attachments/assets/8fff99a3-601e-4939-a18b-5ced1ffcb4ea)

2. Le ratio du stock 2023
![image](https://github.com/user-attachments/assets/fa948989-224b-47c9-b0da-d385e378a485)

WITH stock2023 AS (
SELECT  productName,
		quantityInstock AS stock_act,
                	round(quantityinstock * 365 / sum(quantityOrdered) ) as ratio_stock,
		sum(quantityOrdered) as total_ordered_each_product2023		
	FROM products 
        	INNER JOIN orderdetails USING(productcode)
       	INNER JOIN orders USING (orderNumber)
        	WHERE orderDate BETWEEN '2023-03-04' AND '2024-03-04'
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
ORDER BY stock_act;

![图片1](https://github.com/user-attachments/assets/2504a759-cca7-459c-b1e4-6978de4df8c4)

SELECT SUM(quantityinstock)
from products;  
stock total

![图片2](https://github.com/user-attachments/assets/f3bff17a-5fef-480a-a95c-f78210e0c26e)

SELECT SUM(quantityInStock * buyPrice) AS stock 
FROM products;
le coût du stock total

![图片3](https://github.com/user-attachments/assets/ba8e2eac-8a99-4ea2-aeec-715c1a8c92e0)


SELECT sum(quantityOrdered * priceEach) as total_ordered_each_product2023
FROM orderdetails
INNER JOIN orders USING (orderNumber)
WHERE orderDate BETWEEN '2023-01-01' AND '2023-12-31';
le CA du 2023

![图片4](https://github.com/user-attachments/assets/f25d2868-c6e4-4f8d-9591-21a051522967)

Donc le stock de le coût du stock actuel est 3053685.28 euros qui est représenté 31% de CA du 2023.

3.CA par office par pays
![image](https://github.com/user-attachments/assets/463de90f-bdf3-4c0e-8bda-0b704d16b375)

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

![图片5](https://github.com/user-attachments/assets/e4941f34-d94e-4a8a-b58b-b08f4521e697)

