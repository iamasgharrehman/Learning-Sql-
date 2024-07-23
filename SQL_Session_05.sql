-- creating the database

CREATE DATABASE bootcamp;

-- using database
USE bootcamp;

-- declaring the primay and foreign keys
ALTER TABLE customer
ADD PRIMARY KEY (customer_id);

ALTER TABLE products
ADD PRIMARY KEY (product_id);

ALTER TABLE purchase_history
ADD PRIMARY KEY (purchase_id);

ALTER TABLE purchase_history
ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id);

ALTER TABLE purchase_history
ADD CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id);

-- change the datatype as per requirement and fixing the foramt using str_date function
SET sql_safe_updates = 0;
UPDATE customer
SET date_of_birth = STR_TO_DATE(date_of_birth, "%m/%d/%Y");
SELECT * FROM customer;
ALTER TABLE customer
MODIFY date_of_birth DATE;


UPDATE customer
SET signup_date = STR_TO_DATE(signup_date, "%m/%d/%Y");
SELECT * FROM customer;
ALTER TABLE customer
MODIFY signup_date DATE;

UPDATE purchase_history
SET purchase_date = STR_TO_DATE(purchase_date, "%m/%d/%Y %H:%i" );
SELECT * FROM customer;
ALTER TABLE customer
MODIFY signup_date DATETIME;


/* join
full join using union along with left and right join
inner join => to check the duplicate on a coolumns 
*/

SELECT 
    c.*, ph.*
FROM
    customer c
        LEFT JOIN
    purchase_history ph ON c.customer_id = ph.customer_id 
UNION SELECT 
    c.*, ph.*
FROM
    customer c
        RIGHT JOIN
    purchase_history ph ON c.customer_id = ph.customer_id;

-- inner join
-- find product within same category
SELECT 
    p1.product_name, p2.product_name, p1.category
FROM
    products p1
        JOIN
    products p2 ON p1.category = p2.category
        AND p1.product_id != p2.product_id;
        
-- customer with same city
SELECT 
    CONCAT(c1.first_name, ' ', c1.last_name) AS c1_full_name,
    CONCAT(c2.first_name, ' ', c2.last_name) AS c2_last_name,
    c1.city
FROM
    customer c1
        JOIN
    customer c2 ON c1.city = c2.city
        AND c1.customer_id <> c2.customer_id;
        
-- which products has similar prices
SELECT 
p1.product_id as p1_product_id,
    p1.product_name as p1_product_name,
    p2.product_id as p2_product_id,
    p2.product_name AS p2_product_name,
    p1.price_per_unit AS p1_price,
    p2.price_per_unit as p2_price,
    ABS(p1.price_per_unit - p2.price_per_unit) AS price_diff
FROM
    products p1
        JOIN
    products p2 ON p1.product_id < p2.product_id
    where ABS(p1.price_per_unit - p2.price_per_unit) < 4;
    
    
-- cross join cartian product
-- pair each catogory with brands
SELECT DISTINCT
    (p1.category), p2.brand
FROM
    products p1
        CROSS JOIN
    products p2
ORDER BY p1.category , p2.brand;



-- sub quries / nested quries
select * from products where price_per_unit > (select avg(price_per_unit) from products);

/* 
signle row sub qurie -> aggrigate functions
multi row subqurie -> multiple row and a single column
multi columns sub qurie -> multiple columns and rows
subquries can be used within select, where, from and case statements
*/

-- single row sub quries
-- single row and single coulmn i.e single values
-- display details of product which has the highest price
SELECT 
    *
FROM
    products
ORDER BY price_per_unit DESC
LIMIT 1; -- using order by


SELECT 
    *
FROM
    products
WHERE
    price_per_unit = (SELECT 
            MAX(price_per_unit)
        FROM
            products);
            
            
-- multi rows sub qurey
-- returns multi rows and a single column, mostly used with operater like IN
-- find prodcuts details for product that has been purchased
-- using sub qurey
SELECT 
    *
FROM
    products
WHERE
    product_id IN (SELECT DISTINCT
            (product_id)
        FROM
            purchase_history);
-- using joins
SELECT DISTINCT
    p.*
FROM
    products p
        INNER JOIN
    purchase_history ph ON p.product_id = ph.product_id;

-- list the name of customers who have made pruchases of a product with a specfic product id

SELECT 
    first_name, customer_id
FROM
    customer
WHERE
    customer_id IN (SELECT 
            customer_id
        FROM
            purchase_history
        WHERE
            product_id = 1)
;

-- subqurey in select statement
-- how many prodcuts are there i database and is the total sales amount across prodcuts
-- using sub qurey
select count(*) total_products, (select sum(total_amount) from purchase_history) as total_sales from products;


-- subquries in case statement
-- label product as expensive if values is greater the avg else not expensive 

-- using if statement
SELECT 
    *,
    IF(price_per_unit > (SELECT 
                AVG(price_per_unit)
            FROM
                products),
        'Expensive',
        'Not Expensive') AS price_status
FROM
    products;
    
-- using case statment
SELECT 
    *,
    CASE
        WHEN
            price_per_unit > (SELECT 
                    AVG(price_per_unit)
                FROM
                    products)
        THEN
            'Expensive'
        ELSE 'Not Expensive'
    END AS price_status
FROM
    products;