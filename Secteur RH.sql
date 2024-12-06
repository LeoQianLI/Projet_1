###  Chaque mois, chiffre d'affaire par employer
  
with employees_chiffre_affaire as(
SELECT  concat(e.firstName, ' ', e.lastName) as nom,
        date_format(o.orderDate,"%Y-%m") as dates, 
        d.officeCode, d.city, d.country,
		SUM(quantityOrdered*priceEach) AS Chiffre_Affaire,
rank() over(partition by date_format(o.orderDate,"%Y-%m") order by SUM(quantityOrdered*priceEach)) as rank_CA
FROM offices AS d
	JOIN employees AS e ON d.officeCode=e.officeCode
	JOIN customers AS c ON e.employeeNumber=c.salesRepEmployeeNumber
	join orders  AS o ON c.customerNumber=o.customerNumber
	JOIN orderdetails AS ord ON o.orderNumber=ord.orderNumber
where jobtitle like '%rep%'
group by e.firstName, e.lastName, d.officeCode, d.city, d.country, date_format(o.orderDate,"%Y-%m")
),
total_emp_offices as (
select officecode, count(distinct employeenumber) as total_vendeur_par_office from employees
left join offices using(officecode)
where jobtitle like '%rep%'
group by officecode)
select *, count(*) over(partition by dates) as total_vendeur_actif_mois
from employees_chiffre_affaire
join total_emp_offices USING(officecode);


--------------------------------------------------------------------------------------------------------
### Répartition géographique des clients VS des offices

customer_info as (
select  c.city, c.country, 'client' as category, SUM(quantityOrdered*priceEach) as chiffre_affaire
from customers as c
	JOIN orders  AS od ON c.customerNumber=od.customerNumber
	JOIN orderdetails AS ord ON od.orderNumber=ord.orderNumber
    group by c.city, c.country, category
),
 offices_info as (
select  o.city , o.country,'offices' as category, SUM(quantityOrdered*priceEach) as chiffre_affaire
from offices as o
	JOIN employees AS e ON o.officeCode=e.officeCode
	JOIN customers AS c ON e.employeeNumber=c.salesRepEmployeeNumber
	JOIN orders  AS od ON c.customerNumber=od.customerNumber
	JOIN orderdetails AS ord ON od.orderNumber=ord.orderNumber
    group by o.city, o.country, category
), 
poid_bussness as (
select * 
from offices_info 
union  
select *
from customer_info)
select * 
from poid_bussness;

------------------------------------------------------------------------------------------------------
