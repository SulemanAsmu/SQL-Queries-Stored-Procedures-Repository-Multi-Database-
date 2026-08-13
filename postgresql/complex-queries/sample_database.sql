-- =============================================
-- Database:    PostgreSQL 15
-- Author:      Suleman
-- Description: Sample Company Database Setup
-- =============================================

-- Run this in psql or pgAdmin
-- createdb CompanyDB  (run in terminal first)

\c companydb;

DROP TABLE IF EXISTS AuditLog, OrderDetails, Orders,
                     Products, Customers, Employees,
                     Departments CASCADE;

CREATE TABLE Departments (
    DepartmentID    SERIAL          PRIMARY KEY,
    DepartmentName  VARCHAR(100)    NOT NULL,
    Location        VARCHAR(100),
    Budget          NUMERIC(15,2),
    CreatedDate     TIMESTAMP       DEFAULT NOW()
);

CREATE TABLE Employees (
    EmployeeID      SERIAL          PRIMARY KEY,
    FirstName       VARCHAR(50)     NOT NULL,
    LastName        VARCHAR(50)     NOT NULL,
    Email           VARCHAR(100)    UNIQUE NOT NULL,
    Phone           VARCHAR(20),
    HireDate        DATE            NOT NULL,
    Salary          NUMERIC(10,2)   NOT NULL CHECK (Salary > 0),
    DepartmentID    INT             REFERENCES Departments(DepartmentID),
    ManagerID       INT             REFERENCES Employees(EmployeeID),
    JobTitle        VARCHAR(100),
    Status          VARCHAR(20)     DEFAULT 'Active'
);

CREATE TABLE Customers (
    CustomerID      SERIAL          PRIMARY KEY,
    FirstName       VARCHAR(50)     NOT NULL,
    LastName        VARCHAR(50)     NOT NULL,
    Email           VARCHAR(100)    UNIQUE NOT NULL,
    Phone           VARCHAR(20),
    City            VARCHAR(50),
    Country         VARCHAR(50),
    JoinDate        DATE            DEFAULT CURRENT_DATE
);

CREATE TABLE Products (
    ProductID       SERIAL          PRIMARY KEY,
    ProductName     VARCHAR(100)    NOT NULL,
    Category        VARCHAR(50),
    Price           NUMERIC(10,2)   NOT NULL CHECK (Price > 0),
    StockQuantity   INT             DEFAULT 0,
    CreatedDate     TIMESTAMP       DEFAULT NOW()
);

CREATE TABLE Orders (
    OrderID         SERIAL          PRIMARY KEY,
    CustomerID      INT             REFERENCES Customers(CustomerID),
    EmployeeID      INT             REFERENCES Employees(EmployeeID),
    OrderDate       TIMESTAMP       DEFAULT NOW(),
    TotalAmount     NUMERIC(10,2)   DEFAULT 0,
    Status          VARCHAR(20)     DEFAULT 'Pending',
    ShippingCity    VARCHAR(50)
);

CREATE TABLE OrderDetails (
    OrderDetailID   SERIAL          PRIMARY KEY,
    OrderID         INT             REFERENCES Orders(OrderID),
    ProductID       INT             REFERENCES Products(ProductID),
    Quantity        INT             NOT NULL CHECK (Quantity > 0),
    UnitPrice       NUMERIC(10,2)   NOT NULL,
    Discount        NUMERIC(5,2)    DEFAULT 0
);

CREATE TABLE AuditLog (
    AuditID         SERIAL          PRIMARY KEY,
    TableName       VARCHAR(50),
    Action          VARCHAR(20),
    RecordID        INT,
    ChangedBy       VARCHAR(100),
    ChangedDate     TIMESTAMP       DEFAULT NOW(),
    OldValue        TEXT,
    NewValue        TEXT
);

-- Insert same sample data
INSERT INTO Departments (DepartmentName, Location, Budget) VALUES
    ('Information Technology','New York',500000),
    ('Human Resources','Los Angeles',300000),
    ('Sales','Chicago',750000),
    ('Finance','New York',600000),
    ('Operations','Houston',450000);

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

-- (Add same Customers, Products, Orders, OrderDetails inserts as MySQL above)

SELECT '✅ PostgreSQL CompanyDB Created!' AS status;
