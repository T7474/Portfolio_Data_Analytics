
-- สร้างตารางใหม่ที่มี Column และ Data Type ตรงกับไฟล์ CSV
CREATE TABLE public.customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(100),
    contact_name VARCHAR(100),
    contact_title VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE categories (
	category_id INT PRIMARY KEY,
	category_name VARCHAR(50),
	description VARCHAR(100)
);

CREATE TABLE shippers (
	shiping_id INT PRIMARY KEY,
	company_name VARCHAR(50)
);

DROP TABLE order_details;

CREATE TABLE public.order_details (
    order_id INT,
    product_id INT,
    unit_price NUMERIC(10, 2),
    quantity INT,
    discount NUMERIC(10, 2),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE products (
	product_id INT PRIMARY KEY,
	product_name VARCHAR(50),
	quantity_per_unit VARCHAR(50),
	unit_price NUMERIC(10,2),
	discontinued INT,
	category_id INT
);

CREATE TABLE employees (
	employee_id INT PRIMARY KEY,
	employee_name VARCHAR(50),
	title VARCHAR(50),
	city VARCHAR(50),
	country VARCHAR(10),
	reports_to INT
);
