SELECT * FROM products;
SELECT * FROM order_details;

-- Subquery ใน WHERE
SELECT product_name, 
	unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)

-- Subquery กับ IN
SELECT product_name 
FROM products
WHERE product_id IN (
	SELECT product_id 
	FROM order_details
	WHERE quantity > 50
);

-- CTE
WITH category_avg AS (
    SELECT 
        category_id,
        AVG(unit_price) AS avg_cat_price
    FROM products
    GROUP BY category_id
)
SELECT 
    p.product_name, 
    p.unit_price,
    c.avg_cat_price
FROM products p
JOIN category_avg c ON p.category_id = c.category_id 
WHERE p.unit_price > c.avg_cat_price;

--window function
--Ranking Functions
SELECT
    product_name,
    unit_price,
    ROW_NUMBER() OVER(ORDER BY unit_price DESC) AS row_num,
    RANK() OVER(ORDER BY unit_price DESC) AS rank_num,
    DENSE_RANK() OVER(ORDER BY unit_price DESC) AS dense_rank_num
FROM products;

--Aggregate
SELECT
	product_name,
	unit_price,
	SUM(unit_price) OVER() AS total_price,
	AVG(unit_price) OVER() AS avg_price,
	COUNT(*) OVER() AS count_price,
	unit_price - AVG(unit_price) OVER() AS diff_from_avg
FROM products;

--running_total
SELECT
    product_id,
    unit_price,
    SUM(unit_price) OVER (ORDER BY product_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM products;
	
