-- =============================================
-- Database:    MySQL 8.0
-- Author:      Suleman
-- Description: Sample Company Database Setup
-- =============================================

DROP DATABASE IF EXISTS CompanyDB;
CREATE DATABASE CompanyDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE CompanyDB;

CREATE TABLE Departments (
    DepartmentID    INT             AUTO_INCREMENT PRIMARY KEY,
    DepartmentName  VARCHAR(100)    NOT NULL,
    Location        VARCHAR(100),
    Budget          DECIMAL(15,2),
    CreatedDate     DATETIME        DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Employees (
    EmployeeID      INT             AUTO_INCREMENT PRIMARY KEY,
    FirstName       VARCHAR(50)     NOT NULL,
    LastName        VARCHAR(50)     NOT NULL,
    Email           VARCHAR(100)    UNIQUE NOT NULL,
    Phone           VARCHAR(20),
    HireDate        DATE            NOT NULL,
    Salary          DECIMAL(10,2)   NOT NULL,
    DepartmentID    INT,
    ManagerID       INT,
    JobTitle        VARCHAR(100),
    Status          VARCHAR(20)     DEFAULT 'Active',
    CONSTRAINT fk_emp_dept FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID),
    CONSTRAINT fk_emp_mgr  FOREIGN KEY (ManagerID)
        REFERENCES Employees(EmployeeID),
    CONSTRAINT chk_salary  CHECK (Salary > 0)
);

CREATE TABLE Customers (
    CustomerID      INT             AUTO_INCREMENT PRIMARY KEY,
    FirstName       VARCHAR(50)     NOT NULL,
    LastName        VARCHAR(50)     NOT NULL,
    Email           VARCHAR(100)    UNIQUE NOT NULL,
    Phone           VARCHAR(20),
    City            VARCHAR(50),
    Country         VARCHAR(50),
    JoinDate        DATE            DEFAULT (CURRENT_DATE)
);

CREATE TABLE Products (
    ProductID       INT             AUTO_INCREMENT PRIMARY KEY,
    ProductName     VARCHAR(100)    NOT NULL,
    Category        VARCHAR(50),
    Price           DECIMAL(10,2)   NOT NULL,
    StockQuantity   INT             DEFAULT 0,
    CreatedDate     DATETIME        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_price CHECK (Price > 0)
);

CREATE TABLE Orders (
    OrderID         INT             AUTO_INCREMENT PRIMARY KEY,
    CustomerID      INT,
    EmployeeID      INT,
    OrderDate       DATETIME        DEFAULT CURRENT_TIMESTAMP,
    TotalAmount     DECIMAL(10,2)   DEFAULT 0,
    Status          VARCHAR(20)     DEFAULT 'Pending',
    ShippingCity    VARCHAR(50),
    CONSTRAINT fk_ord_cust FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),
    CONSTRAINT fk_ord_emp  FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID)
);

CREATE TABLE OrderDetails (
    OrderDetailID   INT             AUTO_INCREMENT PRIMARY KEY,
    OrderID         INT,
    ProductID       INT,
    Quantity        INT             NOT NULL,
    UnitPrice       DECIMAL(10,2)   NOT NULL,
    Discount        DECIMAL(5,2)    DEFAULT 0,
    CONSTRAINT fk_od_order   FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),
    CONSTRAINT fk_od_product FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),
    CONSTRAINT chk_qty CHECK (Quantity > 0)
);

CREATE TABLE AuditLog (
    AuditID         INT             AUTO_INCREMENT PRIMARY KEY,
    TableName       VARCHAR(50),
    Action          VARCHAR(20),
    RecordID        INT,
    ChangedBy       VARCHAR(100),
    ChangedDate     DATETIME        DEFAULT CURRENT_TIMESTAMP,
    OldValue        TEXT,
    NewValue        TEXT
);

-- Insert Sample Data (same values as Oracle)
INSERT INTO Departments (DepartmentName, Location, Budget) VALUES
    ('Information Technology', 'New York',   500000),
    ('Human Resources',        'Los Angeles', 300000),
    ('Sales',                  'Chicago',     750000),
    ('Finance',                'New York',    600000),
    ('Operations',             'Houston',     450000);

INSERT INTO Employees
    (FirstName,LastName,Email,Phone,HireDate,Salary,DepartmentID,ManagerID,JobTitle)
VALUES
    ('James','Wilson','james.wilson@company.com','555-0101','2018-03-15',95000,1,NULL,'IT Manager'),
    ('Sarah','Johnson','sarah.johnson@company.com','555-0102','2019-06-01',75000,1,1,'DBA'),
    ('Michael','Brown','michael.brown@company.com','555-0103','2020-01-10',70000,1,1,'Developer'),
    ('Emily','Davis','emily.davis@company.com','555-0104','2017-09-20',85000,2,NULL,'HR Manager'),
    ('Robert','Miller','robert.miller@company.com','555-0105','2021-04-05',65000,2,4,'HR Specialist'),
    ('Jessica','Taylor','jessica.taylor@company.com','555-0106','2016-11-30',90000,3,NULL,'Sales Manager'),
    ('David','Anderson','david.anderson@company.com','555-0107','2022-02-14',60000,3,6,'Sales Rep'),
    ('Lisa','Thomas','lisa.thomas@company.com','555-0108','2019-08-22',80000,4,NULL,'Finance Manager'),
    ('John','Jackson','john.jackson@company.com','555-0109','2020-07-17',72000,4,8,'Accountant'),
    ('Anna','White','anna.white@company.com','555-0110','2021-12-01',68000,5,NULL,'Operations Manager');

INSERT INTO Customers (FirstName,LastName,Email,Phone,City,Country,JoinDate) VALUES
    ('Tom','Harris','tom.harris@email.com','444-0101','New York','USA','2020-01-15'),
    ('Emma','Clark','emma.clark@email.com','444-0102','London','UK','2020-03-22'),
    ('Oliver','Lewis','oliver.lewis@email.com','444-0103','Toronto','Canada','2020-06-10'),
    ('Sophia','Walker','sophia.walker@email.com','444-0104','Sydney','Australia','2021-01-05'),
    ('William','Hall','william.hall@email.com','444-0105','Chicago','USA','2021-04-18'),
    ('Ava','Allen','ava.allen@email.com','444-0106','Dubai','UAE','2021-07-30'),
    ('James','Young','james.young@email.com','444-0107','New York','USA','2022-02-11'),
    ('Isabella','King','isabella.king@email.com','444-0108','Paris','France','2022-05-25'),
    ('Ethan','Wright','ethan.wright@email.com','444-0109','Los Angeles','USA','2022-09-14'),
    ('Mia','Scott','mia.scott@email.com','444-0110','Tokyo','Japan','2023-01-08');

INSERT INTO Products (ProductName,Category,Price,StockQuantity) VALUES
    ('Laptop Pro 15','Electronics',1200,50),
    ('Wireless Mouse','Electronics',25,200),
    ('Office Chair','Furniture',350,30),
    ('Standing Desk','Furniture',599,20),
    ('Monitor 27inch','Electronics',450,45),
    ('Keyboard Mechanical','Electronics',89,150),
    ('Webcam HD','Electronics',75,100),
    ('Headset Pro','Electronics',120,80),
    ('Notebook Set','Stationery',15,500),
    ('USB Hub 7-Port','Electronics',35,120);

INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TotalAmount,Status,ShippingCity) VALUES
    (1,7,'2023-01-10',1225,'Delivered','New York'),
    (2,7,'2023-01-15',475,'Delivered','London'),
    (3,6,'2023-02-01',350,'Delivered','Toronto'),
    (4,6,'2023-02-20',1649,'Delivered','Sydney'),
    (5,7,'2023-03-05',539,'Delivered','Chicago'),
    (6,6,'2023-03-18',120,'Shipped','Dubai'),
    (7,7,'2023-04-02',884,'Shipped','New York'),
    (8,6,'2023-04-15',599,'Processing','Paris'),
    (9,7,'2023-05-01',460,'Processing','Los Angeles'),
    (10,6,'2023-05-20',50,'Pending','Tokyo');

INSERT INTO OrderDetails (OrderID,ProductID,Quantity,UnitPrice,Discount) VALUES
    (1,1,1,1200,0),(1,2,1,25,0),
    (2,5,1,450,0.05),(2,6,1,89,0.05),
    (3,3,1,350,0),(4,1,1,1200,0),(4,4,1,599,0.10),
    (5,5,1,450,0),(5,6,1,89,0),(6,8,1,120,0),
    (7,1,1,1200,0.05),(7,2,2,25,0),
    (8,4,1,599,0),(9,5,1,450,0),(9,2,1,25,0),
    (10,9,2,15,0),(10,2,1,25,0);

COMMIT;
SELECT '✅ MySQL CompanyDB Created Successfully!' AS Status;
