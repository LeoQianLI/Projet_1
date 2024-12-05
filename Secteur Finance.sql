###Les délais de paiement, encours & impayés

WITH ca_payed AS(
	SELECT SUM(amount) AS payed_par_annee, YEAR(paymentDate) AS annee_payment
	FROM payments
	GROUP BY annee_payment
),
ca_commande AS (
    SELECT SUM(quantityOrdered * priceEach) AS commandes_par_annee, YEAR(orderDate) AS annee_commande
    FROM orderdetails od
    JOIN orders ON orders.orderNumber = od.orderNumber
    WHERE status = 'Shipped' - - pour ne prendre en compte que les commandes livrées
    GROUP BY annee_commande
)
SELECT 
	ca_commande.annee_commande AS annee2,
	commandes_par_annee,
    payed_par_annee,
    ca_commande.commandes_par_annee - ca_payed.payed_par_annee AS reste_a_payer,
    (ca_commande.commandes_par_annee - ca_payed.payed_par_annee)/ca_commande.commandes_par_annee*100 AS pourcentage
FROM ca_commande
JOIN ca_payed ON ca_payed.annee_payment = ca_commande.annee_commande
ORDER BY annee2;

-------------------------------------------------------------------------------------------------------------------
### tableau complet par client
WITH ca_payed AS(
	SELECT customerNumber,SUM(amount) AS paid_par_client, MAX(paymentDate) AS dernier_paiement
	FROM payments
	GROUP BY customerNumber
),
ca_commande AS (
    SELECT od.orderNumber, SUM(quantityOrdered * priceEach) AS ca_par_commande
    FROM orderdetails od
    JOIN orders ON orders.orderNumber = od.orderNumber
    WHERE status = 'Shipped'
    GROUP BY od.orderNumber
    
)
SELECT 
	c.customerName, 
	c.customerNumber, 
	SUM(ca_commande.ca_par_commande) AS ca_par_client,
    SUM(CASE
        WHEN YEAR(orderDate)=2022 THEN ca_commande.ca_par_commande
        ELSE 0
        END) AS CA_par_client_2022,
	SUM(CASE
        WHEN YEAR(orderDate)=2023 THEN ca_commande.ca_par_commande
        ELSE 0
        END) AS CA_par_client_2023,
	SUM(CASE
        WHEN YEAR(orderDate)=2024 THEN ca_commande.ca_par_commande
        ELSE 0
        END) AS CA_par_client_2024,
	ca_payed.paid_par_client,
    SUM(ca_commande.ca_par_commande)-ca_payed.paid_par_client AS reste_a_payer,
    (SUM(ca_commande.ca_par_commande)-ca_payed.paid_par_client)*100/(SUM(ca_commande.ca_par_commande)) AS pourcentage,
    ca_payed.dernier_paiement,
		CASE WHEN (SUM(ca_commande.ca_par_commande)-ca_payed.paid_par_client) > 0 AND SUM(CASE
		WHEN YEAR(orderDate)=2024 THEN ca_commande.ca_par_commande
        ELSE 0
		END)=0 AND MONTH(dernier_paiement) <11 THEN 'Rouge'
             WHEN (SUM(ca_commande.ca_par_commande)-ca_payed.paid_par_client) > 0 AND SUM(CASE
		WHEN YEAR(orderDate)=2024 THEN ca_commande.ca_par_commande
        ELSE 0
		END) =0 AND MONTH(dernier_paiement) =12 THEN 'Orange'
             ELSE 0
        END AS Alerte,
	creditLimit,
    ROUND((100*(SUM(ca_commande.ca_par_commande)-ca_payed.paid_par_client)/creditLimit),2) AS jauge_credit
FROM customers AS c
JOIN orders ON c.customerNumber = orders.customerNumber
JOIN ca_commande ON ca_commande.orderNumber = orders.orderNumber
JOIN ca_payed ON ca_payed.customerNumber = c.customerNumber
GROUP BY c.customerName, c.customerNumber
ORDER BY reste_a_payer DESC;

-------------------------------------------------------------------------------------------------------------
### Calcul des marges par produit
### tableau des marges moyennes par produit
  
WITH ca_produit AS(
	SELECT productCode, 
        SUM(quantityOrdered*priceEach) AS CA_par_produit,
        SUM(quantityOrdered) AS quantités_vendues_par_produit
	FROM orderdetails
	GROUP BY productCode
)
SELECT ca_produit.productCode AS code_produit,	
		productName AS nom_du_produit, 
        ca_produit.CA_par_produit,
        ca_produit.quantités_vendues_par_produit,
        ca_produit.CA_par_produit/ca_produit.quantités_vendues_par_produit AS prix_de_vente_moyen_par_produit,
        buyPrice,
        (ca_produit.CA_par_produit/ca_produit.quantités_vendues_par_produit)-buyPrice AS marge_moyenne_par_produit,
        ROUND(100*(((ca_produit.CA_par_produit/ca_produit.quantités_vendues_par_produit)-buyPrice)/buyPrice),2) AS taux_marge_moyenne,
        MSRP,
        ROUND(MSRP-(ca_produit.CA_par_produit/ca_produit.quantités_vendues_par_produit),2) AS remises,
		ROUND(100*((MSRP-(ca_produit.CA_par_produit/ca_produit.quantités_vendues_par_produit))/MSRP),2) AS taux_remises_MSRP
FROM products as p
JOIN ca_produit ON ca_produit.productCode = p.productCode
GROUP BY ca_produit.productCode,ca_produit.CA_par_produit,p.buyPrice
ORDER BY taux_marge_moyenne ASC;

