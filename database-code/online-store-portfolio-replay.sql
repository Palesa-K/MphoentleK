-- ONLINE STORE SQL LAB (portfolio reconstruction)
-- Based on topics demonstrated in the 2025 GA9 assignment.
-- This is a NEW, SANITISED example, not the original submitted transcript.
-- Tested syntactically as MySQL 8+ compatible structure; run in MySQL Workbench/CLI.
-- It uses fictional customers and a disposable demo database.
CREATE DATABASE IF NOT EXISTS portfolio_online_store;
USE portfolio_online_store;

DROP EVENT IF EXISTS ArchiveOldOrders;
DROP TRIGGER IF EXISTS AfterOrderInsert;
DROP PROCEDURE IF EXISTS UpdateStock;
DROP FUNCTION IF EXISTS CalculateDiscount;
DROP TABLE IF EXISTS archived_orders;
DROP TABLE IF EXISTS order_log;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL
);
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE order_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    action VARCHAR(30) NOT NULL,
    logged_at DATETIME NOT NULL
);
CREATE TABLE archived_orders LIKE orders;

INSERT INTO customers (full_name) VALUES ('Example Customer A'),('Example Customer B');
INSERT INTO products (product_name, price, stock_quantity)
VALUES ('Laptop',10000.00,50),('Mouse',150.00,200);

DELIMITER //
CREATE PROCEDURE UpdateStock(IN p_product_id INT, IN p_qty INT)
BEGIN
    IF p_qty <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be positive';
    END IF;
    UPDATE products SET stock_quantity = stock_quantity - p_qty
    WHERE product_id = p_product_id AND stock_quantity >= p_qty;
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unknown product or insufficient stock';
    END IF;
END//

CREATE TRIGGER AfterOrderInsert AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_log (order_id, action, logged_at)
    VALUES (NEW.order_id, 'INSERT', NOW());
END//

-- The GA9 project function calculated a 10% DISCOUNT AMOUNT, not final price.
CREATE FUNCTION CalculateDiscount(p_amount DECIMAL(10,2))
RETURNS DECIMAL(10,2) DETERMINISTIC
RETURN ROUND(p_amount * 0.10, 2)//

-- Optional scheduled event: check event_scheduler configuration before relying on it.
-- Historical archiving logic recreated with order details removed first to respect FK.
-- This example limits archiving to orders with NO order_items (demo only).
CREATE EVENT ArchiveOldOrders
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    INSERT INTO archived_orders
    SELECT o.* FROM orders o
    WHERE o.order_date < CURDATE() - INTERVAL 1 YEAR
      AND NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.order_id);
    DELETE FROM orders
    WHERE order_date < CURDATE() - INTERVAL 1 YEAR
      AND NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = orders.order_id);
END//
DELIMITER ;

-- Example test: AFTER INSERT trigger writes order_log.
INSERT INTO orders (customer_id,order_date,total_amount,status)
VALUES (1,CURDATE(),10150.00,'Pending');
INSERT INTO order_items (order_id,product_id,quantity,price)
VALUES (1,1,1,10000.00),(1,2,1,150.00);

-- Stock update demonstration (50 -> 49).
CALL UpdateStock(1,1);
SELECT product_id, product_name, stock_quantity FROM products;

-- Customer-spending report using a Common Table Expression (CTE).
WITH CustomerTotal AS (
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM orders GROUP BY customer_id
)
SELECT * FROM CustomerTotal ORDER BY total_spent DESC;
SELECT CalculateDiscount(5000.00) AS DiscountAmount;
SELECT * FROM order_log;
-- SHOW VARIABLES LIKE 'event_scheduler'; -- check server state; no auto-activation here
