-- Dataset
CREATE SCHEMA IF NOT EXISTS customer_complains
OPTIONS(
  location="US",
  description="This is my new dataset."
);


-- Table to store customer information
CREATE TABLE IF NOT EXISTS customer_complains.Customers (
    customer_id STRING PRIMARY KEY NOT ENFORCED,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone_number STRING,
    address STRING,
    city STRING,
    postal_code STRING,
    country STRING,
    registration_date TIMESTAMP,
    loyalty_status STRING -- e.g., GOLD, SILVER, BRONZE
);

CREATE TABLE IF NOT EXISTS customer_complains.Products (
    product_id STRING PRIMARY KEY NOT ENFORCED,
    product_name STRING,
    description STRING,
    category STRING,
    unit_price NUMERIC,
    sku STRING,
    in_stock BOOLEAN
);

CREATE TABLE IF NOT EXISTS customer_complains.Orders (
    order_id STRING PRIMARY KEY NOT ENFORCED,
    customer_id STRING NOT NULL,
    order_date TIMESTAMP,
    order_status STRING, -- e.g., PENDING, PROCESSING, PACKED, SHIPPED, DELIVERED, CANCELLED, COMPLETED
    total_amount NUMERIC,
    shipping_address STRING,
    expected_delivery_date DATE,
    actual_delivery_date TIMESTAMP,
    delivery_partner STRING,
    tracking_number STRING,
    FOREIGN KEY (customer_id) REFERENCES `customer_complains`.Customers(customer_id) NOT ENFORCED
);

CREATE TABLE IF NOT EXISTS customer_complains.Order_Items (
    order_item_id STRING PRIMARY KEY NOT ENFORCED,
    order_id STRING NOT NULL,
    product_id STRING NOT NULL,
    quantity INT64,
    unit_price NUMERIC, -- Price at the time of order
    item_status STRING, -- e.g., PICKED, PACKED, SHIPPED, DELIVERED
    FOREIGN KEY (order_id) REFERENCES customer_complains.Orders(order_id) NOT ENFORCED,
    FOREIGN KEY (product_id) REFERENCES customer_complains.Products(product_id) NOT ENFORCED
);

CREATE TABLE IF NOT EXISTS customer_complains.Missing_Item_Complaints (
    complaint_id STRING PRIMARY KEY NOT ENFORCED,
    order_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    product_id STRING NOT NULL, -- The product reported missing
    reported_missing_quantity INT64,
    complaint_date TIMESTAMP,
    status STRING, -- e.g., NEW, UNDER_REVIEW, REFUNDED, ITEM_SENT, REJECTED
    agent_notes STRING,
    resolution_date TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES customer_complains.Orders(order_id) NOT ENFORCED,
    FOREIGN KEY (customer_id) REFERENCES customer_complains.Customers(customer_id) NOT ENFORCED,
    FOREIGN KEY (product_id) REFERENCES customer_complains.Products(product_id) NOT ENFORCED
);

CREATE TABLE IF NOT EXISTS customer_complains.Vouchers (
    voucher_id STRING PRIMARY KEY NOT ENFORCED, -- Application must generate this ID
    customer_id STRING NOT NULL,
    order_id STRING,
    total_amount STRING NOT NULL,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(), -- Default to current timestamp
    expiry_date DATE,
    is_used BOOLEAN DEFAULT FALSE,
    used_date TIMESTAMP,

    FOREIGN KEY (customer_id) REFERENCES customer_complains.Customers(customer_id) NOT ENFORCED,
    FOREIGN KEY (order_id) REFERENCES customer_complains.Orders(order_id) NOT ENFORCED
);


INSERT INTO customer_complains.Vouchers (voucher_id, customer_id, order_id, total_amount) VALUES
('ORD2025001_VOUCHER', 'CUST001', 'ORD2025001' , '50.00');

INSERT INTO customer_complains.Customers (customer_id, first_name, last_name, email, phone_number, address, city, postal_code, country, registration_date, loyalty_status) VALUES
('CUST001', 'Lars', 'Svensson', 'lars.svensson@example.com', '070-1234567', 'Storgatan 1', 'Stockholm', '111 22', 'Sverige', '2023-01-15 10:00:00 UTC', 'GOLD'),
('CUST002', 'Anna', 'Andersson', 'anna.andersson@example.com', '070-2345678', 'Kungsgatan 5', 'Göteborg', '411 11', 'Sverige', '2023-02-20 11:30:00 UTC', 'SILVER'),
('CUST003', 'Mikael', 'Nilsson', 'mikael.nilsson@example.com', '070-3456789', 'Drottninggatan 12', 'Malmö', '211 22', 'Sverige', '2023-03-10 09:15:00 UTC', 'BRONZE'),
('CUST004', 'Eva', 'Johansson', 'eva.johansson@example.com', '070-4567890', 'Vasagatan 20', 'Uppsala', '753 10', 'Sverige', '2023-04-05 14:00:00 UTC', 'SILVER'),
('CUST005', 'Per', 'Olsson', 'per.olsson@example.com', '070-5678901', 'Ågatan 3', 'Linköping', '582 22', 'Sverige', '2023-05-12 16:45:00 UTC', 'GOLD');

INSERT INTO customer_complains.Products (product_id, product_name, description, category, unit_price, sku, in_stock) VALUES
('PROD001', 'Milk', 'Bottle of milk, 1 liter', 'dairy', 12.50, 'SKU1001', TRUE),
('PROD002', 'Coffee', 'Roast, 500g', 'coffee', 45.00, 'SKU1002', TRUE),
('PROD003', 'Cucumber', 'Fresh cucumber, 1 piece', 'fruit & vegetable', 10.00, 'SKU1003', TRUE),
('PROD004', 'Chicken filet', 'Fresh chicken fillet, kg', 'meat', 89.00, 'SKU1004', TRUE),
('PROD005', 'Toiletpaper', '24-pack', 'home', 65.00, 'SKU1005', FALSE),
('PROD006', 'Sliced bread', 'Bread', 'bakery', 22.90, 'SKU1006', TRUE),
('PROD007', 'Bananer', 'Ecologic bananer, kg', 'fruit & vegetable', 25.00, 'SKU1007', TRUE),
('PROD008', 'Eggs', '12-pack', 'dairy', 30.00, 'SKU1008', TRUE),
('PROD009', 'Ketchup', 'Tomatoketchup, 500g', 'side', 18.50, 'SKU1009', TRUE),
('PROD010', 'Butter', '500g', 'dairy', 42.00, 'SKU1010', TRUE);

INSERT INTO customer_complains.Orders (order_id, customer_id, order_date, order_status, total_amount, shipping_address, expected_delivery_date, actual_delivery_date, delivery_partner, tracking_number) VALUES
('ORD2025001', 'CUST001', '2025-10-20 08:15:00 UTC', 'DELIVERED', 250.50, 'Storgatan 1, Stockholm', '2025-10-21', '2025-10-21 14:30:00 UTC', 'PostNord', 'PN123456SE'),
('ORD2025002', 'CUST002', '2025-10-21 12:00:00 UTC', 'DELIVERED', 120.00, 'Kungsgatan 5, Göteborg', '2025-10-22', '2025-10-22 11:00:00 UTC', 'Schenker', 'SC654321SE'),
('ORD2025003', 'CUST001', '2025-10-22 09:30:00 UTC', 'SHIPPED', 85.70, 'Storgatan 1, Stockholm', '2025-10-23', NULL, 'PostNord', 'PN789012SE'),
('ORD2025004', 'CUST003', '2025-10-23 15:00:00 UTC', 'PROCESSING', 350.00, 'Drottninggatan 12, Malmö', '2025-10-25', NULL, NULL, NULL),
('ORD2025005', 'CUST004', '2025-10-24 11:45:00 UTC', 'PACKED', 199.50, 'Vasagatan 20, Uppsala', '2025-10-26', NULL, 'PostNord', NULL);

INSERT INTO customer_complains.Order_Items (order_item_id, order_id, product_id, quantity, unit_price, item_status) VALUES
('ITEM0001', 'ORD2025001', 'PROD001', 2, 12.50, 'DELIVERED'),
('ITEM0002', 'ORD2025001', 'PROD002', 1, 45.00, 'DELIVERED'),
('ITEM0003', 'ORD2025001', 'PROD004', 1, 89.00, 'DELIVERED'),
('ITEM0004', 'ORD2025002', 'PROD003', 5, 10.00, 'DELIVERED'),
('ITEM0005', 'ORD2025002', 'PROD006', 1, 22.90, 'DELIVERED'),
('ITEM0006', 'ORD2025003', 'PROD001', 1, 12.50, 'SHIPPED'),
('ITEM0007', 'ORD2025003', 'PROD009', 2, 18.50, 'SHIPPED'),
('ITEM0008', 'ORD2025004', 'PROD010', 3, 42.00, 'PICKED'),
('ITEM0009', 'ORD2025004', 'PROD007', 2, 25.00, 'PICKED'),
('ITEM0010', 'ORD2025005', 'PROD008', 2, 30.00, 'PACKED');


-- Mock data for Missing_Item_Complaints table
INSERT INTO customer_complains.Missing_Item_Complaints (complaint_id, order_id, customer_id, product_id, reported_missing_quantity, complaint_date, status, agent_notes, resolution_date) VALUES
('COMP001', 'ORD2025001', 'CUST001', 'PROD002', 1, '2025-10-22 09:00:00 UTC', 'RESOLVED_REFUNDED', 'Customer claimed coffee was missing. Verified packing slip, item was missed. Refund issued.', '2025-10-23 10:00:00 UTC'),
('COMP002', 'ORD2025002', 'CUST002', 'PROD003', 2, '2025-10-23 11:00:00 UTC', 'RESOLVED_REJECTED', 'Customer reported 2 cucumbers missing, but order was for 5, and 5 were packed. Weight confirms. Politely rejected.', '2025-10-24 12:00:00 UTC'),
('COMP003', 'ORD2025001', 'CUST001', 'PROD001', 1, '2025-10-22 09:05:00 UTC', 'UNDER_REVIEW', 'Customer claims one milk is missing. Checking warehouse logs.', NULL),
('COMP004', 'ORD2025005', 'CUST004', 'PROD008', 1, '2025-10-27 08:30:00 UTC', 'NEW', 'Order just packed, customer complaining in advance? Order status is PACKED, not yet shipped.', NULL),
('COMP005', 'ORD2025002', 'CUST002', 'PROD006', 1, '2025-10-23 11:00:00 UTC', 'RESOLVED_ITEM_SENT', 'Bread was missing. Sent a new one with next delivery.', '2025-10-25 14:00:00 UTC');


INSERT INTO customer_complains.Order_Items (order_item_id, order_id, product_id, quantity, unit_price, item_status) values ("ITEM0010", "ORD2025003", "PROD003", 1, 20, "DELIVERED")