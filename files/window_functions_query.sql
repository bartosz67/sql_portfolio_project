## cities ordered by revenu
SELECT quantityOrdered * priceEach as revenu,
	   country,
       city
  FROM orders
  JOIN orderdetails USING(orderNumber)
  JOIN customers USING(customerNumber)
 WHERE country != '' -- IS NOT NULL
 GROUP BY city 
 ORDER BY revenu DESC;


## percentage of orders that experienced problems with delivery 
## because the customer did not provide an address 
WITH 
full_orders as (
	SELECT country, city, addressLine1
	  FROM orders
	  JOIN customers USING(customerNumber)
),
no_address_orders as (
	SELECT count(*) as no_address
	  FROM full_orders
	 WHERE country IS NULL
		   OR city IS NULL
		   OR addressLine1 IS NULL
)
SELECT no_address,
	   count(*) as all_orders,
	   (no_address/count(*))*100 as no_adress_percentage
  FROM full_orders
  JOIN no_address_orders;


## how revenue changed over the months
WITH 
monthly_rev as (
	SELECT DATE_FORMAT(orderDate,'%Y-%m') as ordered_month,
		   SUM(quantityOrdered*priceEach) as month_rev
	  FROM orders
	  JOIN orderdetails USING(orderNumber)
	 GROUP BY ordered_month
	 ORDER BY ordered_month
),
monthly_rev_compared as (
SELECT ordered_month,
	   month_rev,
       LAG(month_rev, 1) OVER () as prev_month_rev
  FROM monthly_rev
)
SELECT ordered_month,
       month_rev,
       prev_month_rev,
       month_rev - prev_month_rev as month_rev_gain,
       (month_rev - prev_month_rev)/prev_month_rev*100 as month_rev_perc_gain
  FROM monthly_rev_compared;


# products exclusive to only one vendor
# it turns out all vendors have unique products lol
SELECT productName,
	   productCode,
	   COUNT(productVendor) as no_vendr
  FROM products
 GROUP BY productName, productCode
HAVING no_vendr>1;


# rank offices base on number of employees
SELECT *,
	   CASE -- as office_rank
	     WHEN no_employees BETWEEN 1 AND 2
			  THEN 'small office'
		 WHEN no_employees BETWEEN 3 AND 4
              THEN 'medium office'
		 WHEN no_employees >= 5
              THEN 'big office'
		 ELSE 'error in employees number'
          END as office_rank
  FROM (
		SELECT officeCode as office_code,
			   country,
			   count(*) as no_employees
		  FROM offices
		  JOIN employees USING(officeCode)
		 GROUP by(office_code)
		) as temp;