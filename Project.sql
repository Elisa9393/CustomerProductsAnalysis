-- Exploring the Tables

-- This db contains 8 tables:
-- Table Productlines contains a list of product line categories.
-- Table Products contains a list of scale model cars
-- Table Payments contains customers' payment records
-- Table OrderDetails contains sales order line for each sales order
-- Table Orders contains customers' sales orders
-- Table Offices contains sales office information
-- Table Employees contains all employee information
-- Table Customers contains customer data

-- Displaying the first 5 rows of the products table:

SELECT *
  FROM products
 LIMIT 5;
 
-- Counting lines in the products table:

SELECT COUNT(*)
  FROM products;
 
-- Numbers of rows and attributes in all 8 tables: 

SELECT 'Customers' AS table_name, 
       (SELECT COUNT(*) 
        FROM pragma_table_info('customers')) AS number_of_attributes, 
       (SELECT COUNT(*) 
        FROM customers) AS number_of_rows
UNION ALL
SELECT 'Products' AS table_name, 
       (SELECT COUNT(*) 
        FROM pragma_table_info('products')) AS number_of_attributes, 
       (SELECT COUNT(*) 
        FROM products) AS number_of_rows
UNION ALL
SELECT 'ProductLines' AS table_name, 
       (SELECT COUNT(*) 
        FROM pragma_table_info('productlines')) AS number_of_attributes,  
       (SELECT COUNT(*) 
        FROM productlines) AS number_of_rows
UNION ALL
SELECT 'Orders' AS table_name, 
       (SELECT COUNT(*) 
        FROM pragma_table_info('orders')) AS number_of_attributes,  
       (SELECT COUNT(*) 
        FROM orders) AS number_of_rows
UNION ALL
SELECT 'OrderDetails' AS table_name, 
       (SELECT COUNT(*) 
        FROM pragma_table_info('orderdetails')) AS number_of_attributes,  
       (SELECT COUNT(*) 
        FROM orderdetails) AS number_of_rows
UNION ALL
SELECT 'Payments' AS table_name, 
       (SELECT COUNT(*) 
        FROM pragma_table_info('payments')) AS number_of_attributes,  
       (SELECT COUNT(*) 
        FROM payments) AS number_of_rows
UNION ALL
SELECT 'Employees' AS table_name, 
       (SELECT COUNT(*) 
        FROM pragma_table_info('employees')) AS number_of_attributes,  
       (SELECT COUNT(*) 
        FROM employees) AS number_of_rows
UNION ALL
SELECT 'Offices' AS table_name, 
       (SELECT COUNT(*) 
        FROM pragma_table_info('offices')) AS number_of_attributes,  
       (SELECT COUNT(*) 
        FROM offices) AS number_of_rows
		
-- Question 1: Which Products Should We Order More of or Less of?

WITH low_stock_products AS (
    SELECT 
        od.productCode,
        ROUND(SUM(od.quantityOrdered) / 
            (SELECT p.quantityInStock 
             FROM products p 
             WHERE p.productCode = od.productCode), 2) AS low_stock
    FROM 
        orderdetails od
    GROUP BY 
        od.productCode
)

SELECT 
    od.productCode, p.productName, p.productline,  
    ROUND(SUM(od.quantityOrdered * od.priceEach)) AS priority_products_restock
FROM 
    orderdetails od
JOIN products AS p
  ON od.productCode = p.productCode
WHERE 
    od.productCode IN (
        SELECT productCode 
        FROM low_stock_products
        ORDER BY low_stock ASC
        LIMIT 10
    )
GROUP BY 
    od.productCode
ORDER BY 
    priority_products_restock DESC 
LIMIT 10;

-- Products with a priority for restocking are Classic Cars and Motorcycles.
-- They have a high product performance and are close to being out of stock.


-- Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?

-- VIP Customers:
WITH profit_per_customer AS (
    SELECT o.customerNumber AS CustomerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
      FROM products AS p
      JOIN orderdetails AS od
        ON p.productCode = od.productCode
      JOIN orders AS o
        ON od.orderNumber = o.orderNumber
     GROUP BY o.customerNumber
)

SELECT c.contactLastName, c.contactFirstName, c.city, c.country, ppc.profit
  FROM customers AS c
  JOIN profit_per_customer AS ppc
    ON ppc.CustomerNumber = c.customerNumber
 GROUP BY ppc.customerNumber
 ORDER BY ppc.profit DESC
 LIMIT 5;
 
 -- Less Engaged Customers:
 WITH profit_per_customer AS (
    SELECT o.customerNumber AS CustomerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
      FROM products AS p
      JOIN orderdetails AS od
        ON p.productCode = od.productCode
      JOIN orders AS o
        ON od.orderNumber = o.orderNumber
     GROUP BY o.customerNumber
)

SELECT c.contactLastName, c.contactFirstName, c.city, c.country, ppc.profit
  FROM customers AS c
  JOIN profit_per_customer AS ppc
    ON ppc.CustomerNumber = c.customerNumber
 GROUP BY ppc.customerNumber
 ORDER BY ppc.profit ASC for least  engaged customers
 LIMIT 5;
 
 -- Accordingly, we need to determine how to drive loyalty and attract more customers.
 
 -- Question 3: How Much Can We Spend on Acquiring New Customers?
 
 WITH profit_per_customer AS (
    SELECT o.customerNumber AS CustomerNumber, SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
      FROM products AS p
      JOIN orderdetails AS od
        ON p.productCode = od.productCode
      JOIN orders AS o
        ON od.orderNumber = o.orderNumber
     GROUP BY o.customerNumber
)

SELECT AVG(profit)
  FROM profit_per_customer;
  
 -- Customer Lifetime Value (LTV) tells us how much profit an average customer generates during their lifetime with our store. We can use it to predict our future profit. So, if we get ten new customers next month, we'll earn 390,395 dollars, and we can decide based on this prediction how much we can spend on acquiring new customers.