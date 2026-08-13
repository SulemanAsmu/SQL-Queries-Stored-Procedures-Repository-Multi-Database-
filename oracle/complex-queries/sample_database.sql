
-- =============================================
-- Database:    Oracle 19c/21c
-- Author:      [Your Name]
-- Description: Sample Company Database Setup
--              Used for all Oracle scripts
-- =============================================

-- -----------------------------------------------
-- Drop tables if they exist (Clean Setup)
-- -----------------------------------------------
BEGIN
    FOR t IN (
        SELECT table_name FROM user_tables
        WHERE table_name IN (
            'AUDIT_LOG','ORDER_DETAILS','ORDERS',
            'PRODUCTS','CUSTOMERS','EMPLOYEES','DEPARTMENTS'
        )
    )
    LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/

-- -----------------------------------------------
-- Create Sequences (Oracle uses Sequences
--                  instead of AUTO_INCREMENT)
-- -----------------------------------------------
CREATE SEQUENCE seq_department_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_employee_id   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_customer_id   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_product_id    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_order_id      START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_orderdet_id   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_audit_id      START WITH 1 INCREMENT BY 1;

-- -----------------------------------------------
-- Create Tables
-- -----------------------------------------------

-- Departments Table
CREATE TABLE Departments (
    DepartmentID    NUMBER          DEFAULT seq_department_id.NEXTVAL PRIMARY KEY,
    DepartmentName  VARCHAR2(100)   NOT NULL,
    Location        VARCHAR2(100),
    Budget          NUMBER(15,2),
    CreatedDate     DATE            DEFAULT SYSDATE
);

-- Employees Table
CREATE TABLE Employees (
    EmployeeID      NUMBER          DEFAULT seq_employee_id.NEXTVAL PRIMARY KEY,
    FirstName       VARCHAR2(50)    NOT NULL,
    LastName        VARCHAR2(50)    NOT NULL,
    Email           VARCHAR2(100)   UNIQUE NOT NULL,
    Phone           VARCHAR2(20),
    HireDate        DATE            NOT NULL,
    Salary          NUMBER(10,2)    NOT NULL,
    DepartmentID    NUMBER          REFERENCES Departments(DepartmentID),
    ManagerID       NUMBER          REFERENCES Employees(EmployeeID),
    JobTitle        VARCHAR2(100),
    Status          VARCHAR2(20)    DEFAULT 'Active',
    CONSTRAINT chk_salary CHECK (Salary > 0)
);

-- Customers Table
CREATE TABLE Customers (
    CustomerID      NUMBER          DEFAULT seq_customer_id.NEXTVAL PRIMARY KEY,
    FirstName       VARCHAR2(50)    NOT NULL,
    LastName        VARCHAR2(50)    NOT NULL,
    Email           VARCHAR2(100)   UNIQUE NOT NULL,
    Phone           VARCHAR2(20),
    City            VARCHAR2(50),
    Country         VARCHAR2(50),
    JoinDate        DATE            DEFAULT SYSDATE
);

-- Products Table
CREATE TABLE Products (
    ProductID       NUMBER          DEFAULT seq_product_id.NEXTVAL PRIMARY KEY,
    ProductName     VARCHAR2(100)   NOT NULL,
    Category        VARCHAR2(50),
    Price           NUMBER(10,2)    NOT NULL,
    StockQuantity   NUMBER          DEFAULT 0,
    CreatedDate     DATE            DEFAULT SYSDATE,
    CONSTRAINT chk_price CHECK (Price > 0)
);

-- Orders Table
CREATE TABLE Orders (
    OrderID         NUMBER          DEFAULT seq_order_id.NEXTVAL PRIMARY KEY,
    CustomerID      NUMBER          REFERENCES Customers(CustomerID),
    EmployeeID      NUMBER          REFERENCES Employees(EmployeeID),
    OrderDate       DATE            DEFAULT SYSDATE,
    TotalAmount     NUMBER(10,2)    DEFAULT 0,
    Status          VARCHAR2(20)    DEFAULT 'Pending',
    ShippingCity    VARCHAR2(50)
);

-- OrderDetails Table
CREATE TABLE OrderDetails (
    OrderDetailID   NUMBER          DEFAULT seq_orderdet_id.NEXTVAL PRIMARY KEY,
    OrderID         NUMBER          REFERENCES Orders(OrderID),
    ProductID       NUMBER          REFERENCES Products(ProductID),
    Quantity        NUMBER          NOT NULL,
    UnitPrice       NUMBER(10,2)    NOT NULL,
    Discount        NUMBER(5,2)     DEFAULT 0,
    CONSTRAINT chk_qty CHECK (Quantity > 0)
);

-- AuditLog Table
CREATE TABLE AuditLog (
    AuditID         NUMBER          DEFAULT seq_audit_id.NEXTVAL PRIMARY KEY,
    TableName       VARCHAR2(50),
    Action          VARCHAR2(20),
    RecordID        NUMBER,
    ChangedBy       VARCHAR2(100),
    ChangedDate     DATE            DEFAULT SYSDATE,
    OldValue        CLOB,
    NewValue        CLOB
);

-- -----------------------------------------------
-- Insert Sample Data
-- -----------------------------------------------

-- Departments
INSERT INTO Departments (DepartmentName, Location, Budget)
VALUES ('Information Technology', 'New York',   500000);
INSERT INTO Departments (DepartmentName, Location, Budget)
VALUES ('Human Resources',        'Los Angeles', 300000);
INSERT INTO Departments (DepartmentName, Location, Budget)
VALUES ('Sales',                  'Chicago',     750000);
INSERT INTO Departments (DepartmentName, Location, Budget)
VALUES ('Finance',                'New York',    600000);
INSERT INTO Departments (DepartmentName, Location, Budget)
VALUES ('Operations',             'Houston',     450000);

-- Employees
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('James','Wilson','james.wilson@company.com','555-0101',DATE '2018-03-15',95000,1,NULL,'IT Manager');
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('Sarah','Johnson','sarah.johnson@company.com','555-0102',DATE '2019-06-01',75000,1,1,'DBA');
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('Michael','Brown','michael.brown@company.com','555-0103',DATE '2020-01-10',70000,1,1,'Developer');
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('Emily','Davis','emily.davis@company.com','555-0104',DATE '2017-09-20',85000,2,NULL,'HR Manager');
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('Robert','Miller','robert.miller@company.com','555-0105',DATE '2021-04-05',65000,2,4,'HR Specialist');
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('Jessica','Taylor','jessica.taylor@company.com','555-0106',DATE '2016-11-30',90000,3,NULL,'Sales Manager');
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('David','Anderson','david.anderson@company.com','555-0107',DATE '2022-02-14',60000,3,6,'Sales Rep');
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('Lisa','Thomas','lisa.thomas@company.com','555-0108',DATE '2019-08-22',80000,4,NULL,'Finance Manager');
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('John','Jackson','john.jackson@company.com','555-0109',DATE '2020-07-17',72000,4,8,'Accountant');
INSERT INTO Employees (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES ('Anna','White','anna.white@company.com','555-0110',DATE '2021-12-01',68000,5,NULL,'Operations Manager');

-- Customers
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('Tom','Harris','tom.harris@email.com','444-0101','New York','USA',DATE '2020-01-15');
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('Emma','Clark','emma.clark@email.com','444-0102','London','UK',DATE '2020-03-22');
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('Oliver','Lewis','oliver.lewis@email.com','444-0103','Toronto','Canada',DATE '2020-06-10');
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('Sophia','Walker','sophia.walker@email.com','444-0104','Sydney','Australia',DATE '2021-01-05');
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('William','Hall','william.hall@email.com','444-0105','Chicago','USA',DATE '2021-04-18');
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('Ava','Allen','ava.allen@email.com','444-0106','Dubai','UAE',DATE '2021-07-30');
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('James','Young','james.young@email.com','444-0107','New York','USA',DATE '2022-02-11');
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('Isabella','King','isabella.king@email.com','444-0108','Paris','France',DATE '2022-05-25');
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('Ethan','Wright','ethan.wright@email.com','444-0109','Los Angeles','USA',DATE '2022-09-14');
INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate)
VALUES ('Mia','Scott','mia.scott@email.com','444-0110','Tokyo','Japan',DATE '2023-01-08');

-- Products
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('Laptop Pro 15','Electronics',1200,50);
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('Wireless Mouse','Electronics',25,200);
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('Office Chair','Furniture',350,30);
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('Standing Desk','Furniture',599,20);
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('Monitor 27inch','Electronics',450,45);
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('Keyboard Mechanical','Electronics',89,150);
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('Webcam HD','Electronics',75,100);
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('Headset Pro','Electronics',120,80);
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('Notebook Set','Stationery',15,500);
INSERT INTO Products (ProductName,Category,Price,StockQuantity)
VALUES ('USB Hub 7-Port','Electronics',35,120);

-- Orders
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (1,7,DATE '2023-01-10',1225,'Delivered','New York');
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (2,7,DATE '2023-01-15',475,'Delivered','London');
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (3,6,DATE '2023-02-01',350,'Delivered','Toronto');
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (4,6,DATE '2023-02-20',1649,'Delivered','Sydney');
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (5,7,DATE '2023-03-05',539,'Delivered','Chicago');
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (6,6,DATE '2023-03-18',120,'Shipped','Dubai');
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (7,7,DATE '2023-04-02',884,'Shipped','New York');
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (8,6,DATE '2023-04-15',599,'Processing','Paris');
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (9,7,DATE '2023-05-01',460,'Processing','Los Angeles');
INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity)
VALUES (10,6,DATE '2023-05-20',50,'Pending','Tokyo');

-- Order Details
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (1,1,1,1200,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (1,2,1,25,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (2,5,1,450,0.05);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (2,6,1,89,0.05);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (3,3,1,350,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (4,1,1,1200,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (4,4,1,599,0.10);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (5,5,1,450,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (5,6,1,89,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (6,8,1,120,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (7,1,1,1200,0.05);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (7,2,2,25,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (8,4,1,599,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (9,5,1,450,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (9,2,1,25,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (10,9,2,15,0);
INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount)
VALUES (10,2,1,25,0);

COMMIT;

PROMPT ✅ Oracle CompanyDB created successfully!
