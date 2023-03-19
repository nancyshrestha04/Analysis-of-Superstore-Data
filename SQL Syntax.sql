
-----Main data showing the data from year 2016 - 2019 which also includes --
---calculated columns viz. discount_amount (discount*sa), is_returned and reason_returned_all ---

SELECT DISTINCT   (view1.order_id), view1.order_date, view1.ship_mode, view1.sales, view1.quantity_ordered, view1.profit,
                  view1.discount, view1.discount_amount, view1.customer_id, view1.segment, 
				          view1.product_id, view1.category, view1.sub_category,
                  view1.product_name, view1.is_returned, 
                  CASE 
                  WHEN (view1.is_returned=1) THEN view1.reason_returned 
                  ELSE 'Not Returned' 
                  END AS reason_returned_all 
FROM (
	     SELECT   OD.order_id, OD.order_date, OD.ship_mode, OD.sales, OD.quantity as quantity_ordered, 
	              OD.profit, OD.discount,(OD.sales * OD.discount) as discount_amount, CS.customer_id, 
		            CS.segment, PD.product_id, PD.category, PD.sub_category,                                                                          
                PD.product_name, PD.product_cost_to_consumer, RT.return_date, RT.return_quantity, 
                RT.reason_returned,
	            CASE 
              WHEN (RT.reason_returned = 'Wrong Item' OR RT.reason_returned = 'Wrong Color' OR
				      RT.reason_returned = 'Not Needed' OR RT.reason_returned = 'Not Given') THEN 1
			        ELSE 0 
			        END as is_returned
	     FROM    orders as OD LEFT JOIN returns as RT ON OD.order_id = RT.order_id
	                  JOIN customers as CS ON OD.customer_id = CS.customer_id
	                  JOIN products as PD ON OD.product_id = PD.product_id
	) as view1
WHERE		    date_part('year', view1.order_date) != '2015' 
            AND date_part('year', view1.order_date) != '2020';

-------Which customer segment made the highest number of orders---------
---Used CTE (Common Table Expression)

WITH  ord as
		( SELECT	*
		  FROM		orders
		),
		
	prod as
	    ( SELECT	*
		  FROM		products
		  
		),
		
	cus as
	    ( SELECT	*
		  FROM		customers
		  
		),
	rtn as
	    ( SELECT	*,
		  CASE		WHEN reason_returned = 'Wrong Item' OR reason_returned = 'Wrong Color' OR
				  reason_returned = 'Not Needed' OR reason_returned = 'Not Given' THEN 1
			ELSE 0
			END as is_returned
		  FROM		returns
		)
SELECT		cus.segment, count (DISTINCT ord.order_id)
FROM		ord  LEFT JOIN rtn ON ord.order_id = rtn.order_id
					JOIN prod ON ord.product_id = prod.product_id
					JOIN cus ON ord.customer_id = cus.customer_id
GROUP BY	cus.segment
ORDER BY	2 DESC
LIMIT		3;

---Highest sales made by customer segments in year between 2016 - 2019----

SELECT	cus.segment,sum(ord.sales) as sum_sale	
FROM	orders as ord JOIN customers as cus ON ord.customer_id = cus.customer_id
WHERE		date_part('year', ord.order_date) != '2015' 
        AND date_part('year', ord.order_date) != '2020'
GROUP BY	cus.segment
ORDER BY	sum_sale DESC

----Sum Sale of the three customer segments on preferred year query----

SELECT			cus.segment, ROUND(SUM(ord.sales), 0 ) as sum_sale
FROM			orders as ord JOIN customers as cus ON ord.customer_id = cus.customer_id
WHERE			DATE_Part('year', ord.order_date) = '2018' --(input preferred year)---
GROUP BY		cus.segment
ORDER BY		sum_sale DESC;

------ SUM profit of the three customer segments on particular year----
--- change DATE_Part ('year', ord.order_date) = 'preferred Year'----

SELECT			cus.segment, ROUND(SUM(ord.profit), 0 ) as sum_profit
FROM			orders as ord JOIN customers as cus ON ord.customer_id = cus.customer_id
WHERE			DATE_Part('year', ord.order_date) = '2018'
GROUP BY		cus.segment
ORDER BY		sum_profit DESC

----Which product sub category was highest selling overall ?---

SELECT			prod.sub_category as category, ROUND(SUM(ord.sales), 0 ) as sum_sale
FROM			orders as ord JOIN products as prod on ord.product_id = prod.product_id
GROUP BY		prod.sub_category
ORDER BY		sum_sale DESC;

---Top 5 highest selling product in Phone category?

SELECT			prod.product_name, ROUND(SUM(ord.sales), 0 ) as sum_sale
FROM			orders as ord JOIN products as prod ON ord.product_id = prod.product_id
WHERE			prod.sub_category = 'Phones'
GROUP BY		prod.product_name
ORDER BY		sum_sale DESC
LIMIT			5;

----which product sub_category made Highest sum profit overall?---

SELECT			prod.sub_category, ROUND(SUM(ord.profit), 0 ) as sum_profit
FROM			orders as ord JOIN products as prod ON ord.product_id = prod.product_id
GROUP BY		prod.sub_category
ORDER BY		sum_profit DESC;

--Highest sum profit of which product sub_category with average discounts---

SELECT			prod.sub_category, ROUND(SUM(ord.profit), 0 ) as sum_profit, avg(ord.discount) as avg_discount
FROM			orders as ord JOIN products as prod ON ord.product_id = prod.product_id

GROUP BY		prod.sub_category
ORDER BY		sum_profit DESC;

-----Top 5 products making the highest profit in 'Copiers' sub-category of products.---
SELECT			prod.product_name, ROUND(SUM(ord.profit), 0 ) as sum_profit, avg(ord.discount) as avg_discount
FROM			orders as ord JOIN products as prod ON ord.product_id = prod.product_id
WHERE			prod.sub_category = 'Copiers'
GROUP BY		prod.product_name
ORDER BY		sum_profit DESC
LIMIT			5;


 ---Superstore data with only returns items (2016 - 2019).----
 
 SELECT		    temp1.order_id, temp1.order_date, temp1.ship_mode, temp1.sales, temp1.quantity_ordered, temp1.profit, temp1.discount,
 				temp1.discount_amount, temp1.customer_id, temp1.segment,temp1.product_id, temp1.category, temp1.sub_category,
				temp1.product_name, temp1.reason_returned_all
FROM         
            (
SELECT          view1.order_id, view1.order_date, view1.ship_mode, view1.sales, view1.quantity_ordered, view1.profit,
                view1.discount, view1.discount_amount, view1.customer_id, view1.segment, 
				view1.product_id, view1.category, view1.sub_category,
                view1.product_name, view1.is_returned, 
    CASE WHEN (view1.is_returned=1) THEN view1.reason_returned ELSE 'Not Returned' 
    END as reason_returned_all 
FROM (
	SELECT OD.order_id, OD.order_date, OD.ship_mode, OD.sales, OD.quantity as quantity_ordered, 
	       OD.profit, OD.discount,(OD.sales * OD.discount) as discount_amount, CS.customer_id, 
		   CS.segment, PD.product_id, PD.category, PD.sub_category,                                                                          
           PD.product_name, PD.product_cost_to_consumer, RT.return_date, RT.return_quantity, 
           RT.reason_returned,
	   CASE WHEN (RT.reason_returned = 'Wrong Item' OR RT.reason_returned = 'Wrong Color' OR
				  RT.reason_returned = 'Not Needed' OR RT.reason_returned = 'Not Given') THEN 1
			ELSE 0 
			END as is_returned
	FROM orders as OD LEFT JOIN returns as RT ON OD.order_id = RT.order_id
	                  JOIN customers as CS ON OD.customer_id = CS.customer_id
	                  JOIN products as PD ON OD.product_id = PD.product_id
	) as view1
WHERE		date_part('year', view1.order_date) != '2015' AND date_part('year', view1.order_date) != '2020' 
			) as temp1
WHERE		temp1.reason_returned_all != 'Not Returned'

--- number of returns based on reason returned (2016 - 2019)----

SELECT		    temp1.reason_returned_all ,count(DISTINCT temp1.order_id) as number_of_returns
FROM         
            (
SELECT          view1.order_id, view1.order_date, view1.ship_mode, view1.sales, view1.quantity_ordered, view1.profit,
                view1.discount, view1.discount_amount, view1.customer_id, view1.segment, 
				view1.product_id, view1.category, view1.sub_category,
                view1.product_name, view1.is_returned, 
    CASE when (view1.is_returned=1) THEN view1.reason_returned ELSE 'Not Returned' 
    END as reason_returned_all 
FROM (
	SELECT OD.order_id, OD.order_date, OD.ship_mode, OD.sales, OD.quantity as quantity_ordered, 
	       OD.profit, OD.discount,(OD.sales * OD.discount) as discount_amount, CS.customer_id, 
		   CS.segment, PD.product_id, PD.category, PD.sub_category,                                                                          
           PD.product_name, PD.product_cost_to_consumer, RT.return_date, RT.return_quantity, 
           RT.reason_returned,
	   CASE WHEN (RT.reason_returned = 'Wrong Item' OR RT.reason_returned = 'Wrong Color' OR
				  RT.reason_returned = 'Not Needed' OR RT.reason_returned = 'Not Given') THEN 1
			ELSE 0 
			END as is_returned
	FROM orders as OD LEFT JOIN returns as RT ON OD.order_id = RT.order_id
	                  JOIN customers as CS ON OD.customer_id = CS.customer_id
	                  JOIN products as PD ON OD.product_id = PD.product_id
	) as view1
WHERE		date_part('year', view1.order_date) != '2015' AND date_part('year', view1.order_date) != '2020' ) as temp1

 WHERE		temp1.reason_returned_all != 'Not Returned'
 GROUP BY	temp1.reason_returned_all
 ORDER BY	number_of_returns DESC;
 

--Highest number of returns based on return reason (2016 -  2019)---

 
SELECT		    temp1.reason_returned_all,count(DISTINCT temp1.order_id) as number_of_returns
FROM         
            (
        SELECT          view1.order_id, view1.order_date, view1.ship_mode, view1.sales, view1.quantity_ordered, view1.profit,
                view1.discount, view1.discount_amount, view1.customer_id, view1.segment, 
				view1.product_id, view1.category, view1.sub_category,
                view1.product_name, view1.is_returned, 
            CASE WHEN (view1.is_returned=1) THEN view1.reason_returned ELSE 'Not Returned' 
            END as reason_returned_all 
        FROM (
	        SELECT OD.order_id, OD.order_date, OD.ship_mode, OD.sales, OD.quantity as quantity_ordered, 
	       OD.profit, OD.discount,(OD.sales * OD.discount) as discount_amount, CS.customer_id, 
		   CS.segment, PD.product_id, PD.category, PD.sub_category,                                                                          
           PD.product_name, PD.product_cost_to_consumer, RT.return_date, RT.return_quantity, 
           RT.reason_returned,
	            CASE WHEN (RT.reason_returned = 'Wrong Item' OR RT.reason_returned = 'Wrong Color' OR
				  RT.reason_returned = 'Not Needed' OR RT.reason_returned = 'Not Given') THEN 1
			    ELSE 0 
			    END as is_returned
	        FROM orders as OD LEFT JOIN returns as RT ON OD.order_id = RT.order_id
	                  JOIN customers as CS ON OD.customer_id = CS.customer_id
	                  JOIN products as PD ON OD.product_id = PD.product_id
	) as view1
        WHERE		date_part('year', view1.order_date) != '2015' AND date_part('year', view1.order_date) != '2020' 
            ) as temp1
 WHERE		temp1.reason_returned_all != 'Not Returned'
 GROUP BY	temp1.reason_returned_all
 ORDER BY	number_of_returns DESC;

 ----number of returns of product sub-category in descending order  between year 2016 - 2019 query---

SELECT		    temp1.sub_category, sum(temp1.is_returned) as number_of_returns
FROM         
            (
SELECT          view1.order_id, view1.order_date, view1.ship_mode, view1.sales, view1.quantity_ordered, view1.profit,
                view1.discount, view1.discount_amount, view1.customer_id, view1.segment, 
				view1.product_id, view1.category, view1.sub_category,
                view1.product_name, view1.is_returned, 
    CASE WHEN (view1.is_returned=1) THEN view1.reason_returned ELSE 'Not Returned' 
    END as reason_returned_all 
FROM (
	select OD.order_id, OD.order_date, OD.ship_mode, OD.sales, OD.quantity as quantity_ordered, 
	       OD.profit, OD.discount,(OD.sales * OD.discount) as discount_amount, CS.customer_id, 
		   CS.segment, PD.product_id, PD.category, PD.sub_category,                                                                          
           PD.product_name, PD.product_cost_to_consumer, RT.return_date, RT.return_quantity, 
           RT.reason_returned,
	   CASE WHEN (RT.reason_returned = 'Wrong Item' OR RT.reason_returned = 'Wrong Color' OR
				  RT.reason_returned = 'Not Needed' OR RT.reason_returned = 'Not Given') THEN 1
			ELSE 0 
			END as is_returned
	FROM orders as OD LEFT JOIN returns as RT ON OD.order_id = RT.order_id
	                  JOIN customers as CS ON OD.customer_id = CS.customer_id
	                  JOIN products as PD ON OD.product_id = PD.product_id
	) as view1
WHERE		date_part('year', view1.order_date) != '2015' AND date_part('year', view1.order_date) != '2020' 
			) as temp1
WHERE		temp1.reason_returned_all != 'Not Returned'
GROUP BY	temp1.sub_category;

------Most sold product sub-category by 'Consumer' customers between year 2016- 2019---

SELECT		    temp1.sub_category, Round(sum(temp1.sales),0) as sum_sale
FROM         
            (
SELECT          view1.order_id, view1.order_date, view1.ship_mode, view1.sales, view1.quantity_ordered, view1.profit,
                view1.discount, view1.discount_amount, view1.customer_id, view1.segment, 
				view1.product_id, view1.category, view1.sub_category,
                view1.product_name, view1.is_returned, 
    CASE WHEN (view1.is_returned=1) THEN view1.reason_returned ELSE 'Not Returned' 
    END as reason_returned_all 
FROM (
	SELECT OD.order_id, OD.order_date, OD.ship_mode, OD.sales, OD.quantity as quantity_ordered, 
	       OD.profit, OD.discount,(OD.sales * OD.discount) as discount_amount, CS.customer_id, 
		   CS.segment, PD.product_id, PD.category, PD.sub_category,                                                                          
           PD.product_name, PD.product_cost_to_consumer, RT.return_date, RT.return_quantity, 
           RT.reason_returned,
	   CASE WHEN (RT.reason_returned = 'Wrong Item' OR RT.reason_returned = 'Wrong Color' OR
				  RT.reason_returned = 'Not Needed' OR RT.reason_returned = 'Not Given') THEN 1
			ELSE 0 
			END as is_returned
	FROM orders as OD LEFT JOIN returns as RT ON OD.order_id = RT.order_id
	                  JOIN customers as CS ON OD.customer_id = CS.customer_id
	                  JOIN products as PD ON OD.product_id = PD.product_id
	) as view1
WHERE		date_part('year', view1.order_date) != '2015' AND date_part('year', view1.order_date) != '2020' 
			) as temp1
WHERE		temp1.segment = 'Consumer'
GROUP BY	temp1.sub_category
ORDER BY	sum_sale desc

------- Sum sales country wise (2016 - 2019)---

SELECT			reg.country, SUM(ord.sales) as sum_sales
FROM			orders as ord JOIN regions as reg ON ord.region_id = reg.region_id
WHERE			date_part('year', ord.order_date) != '2015' 
				AND date_part('year', ord.order_date) != '2020' 
GROUP BY		reg.country
ORDER BY		sum_sales DESC;


---Top 5 most profitable Copiers (2016 - 2019)---

SELECT		prod.product_name, sum(ord.profit) as sum_profit
FROM		orders as ord JOIN products as prod on ord.product_id = prod.product_id
WHERE		DATE_PART('year', ord.order_date) != '2015' AND DATE_PART('year', ord.order_date) != '2020'  
			AND prod.sub_category = 'Copiers'
GROUP BY	1
ORDER BY	sum_profit DESC
Limit	5;

---number of returns made by all sub-category (2016-2019)---

SELECT    view1.sub_category, sum(view1.is_returned)
FROM     (
	    SELECT 	*,
		CASE WHEN rtn.reason_returned = 'Wrong Item' or rtn.reason_returned = 'Wrong Color' OR rtn.reason_returned = 'Not Needed' or rtn.reason_returned= 'Not Given' Then 1
		ELSE 0 
		End as is_returned
	    FROM	orders as ord LEFT JOIN returns as rtn ON ord.order_id = rtn.order_id
						   JOIN products as prod ON ord.product_id = prod.product_id ) as view1
WHERE		DATE_part('year', view1.order_date) != '2015' AND 
            DATE_part('year', view1.order_date) != '2020'
GROUP BY	1
ORDER BY	2 desc;

---most returned item in 'Binders' category---

SELECT    view1.product_name, sum(view1.is_returned)
FROM     (
	    select 	*,
		CASE WHEN rtn.reason_returned = 'Wrong Item' or rtn.reason_returned = 'Wrong Color' OR rtn.reason_returned = 'Not Needed' or rtn.reason_returned= 'Not Given' Then 1
		ELSE 0 
		End as is_returned
	   FROM	orders as ord LEFT JOIN returns as rtn ON ord.order_id = rtn.order_id
						   JOIN products as prod ON ord.product_id = prod.product_id ) as view1
WHERE		DATE_part('year', view1.order_date) != '2015' AND 
            DATE_part('year', view1.order_date) != '2020' AND view1.sub_category = 'Binders'
GROUP BY	1
ORDER BY	2 DESC;

----Most returned 'binder' ---

SELECT    view1.product_name, sum(view1.is_returned)
FROM     (
	    SELECT 	*,
		CASE WHEN rtn.reason_returned = 'Wrong Item' or rtn.reason_returned = 'Wrong Color' OR rtn.reason_returned = 'Not Needed' or rtn.reason_returned= 'Not Given' Then 1
		ELSE 0 
		End as is_returned
	    FROM	orders as ord LEFT JOIN returns as rtn ON ord.order_id = rtn.order_id
						   JOIN products as prod ON ord.product_id = prod.product_id ) as view1
WHERE		DATE_part('year', view1.order_date) != '2015' AND 
            DATE_part('year', view1.order_date) != '2020' AND view1.sub_category = 'Binders'
GROUP BY	  1
ORDER BY	  2 desc
Limit		    1;
````
