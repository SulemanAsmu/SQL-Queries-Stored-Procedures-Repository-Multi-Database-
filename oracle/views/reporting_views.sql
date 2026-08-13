-- =============================================
-- Database:    Oracle 19c/21c
-- Author:      Suleman
-- Description: Reporting Views
-- =============================================

-- View 1: Employee Full Details
CREATE OR REPLACE VIEW vw_EmployeeDetails AS
SELECT
    e.EmployeeID,
    e.FirstName || ' ' || e.LastName            AS FullName,
    e.Email,
    e.Phone,
    e.JobTitle,
    e.Salary,
    TO_CHAR(e.HireDate,'DD-MON-YYYY')           AS HireDate,
    e.Status,
    d.DepartmentName,
    d.Location,
    d.Budget                                     AS DeptBudget,
    m.FirstName || ' ' || m.LastName            AS ManagerName,
    TRUNC(MONTHS_BETWEEN(SYSDATE,e.HireDate)/12) AS YearsOfService
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN Employees   m ON e.ManagerID    = m.EmployeeID;

-- View 2: Sales Dashboard
CREATE OR REPLACE VIEW vw_SalesDashboard AS
SELECT
    o.OrderID,
    TO_CHAR(o.OrderDate,'DD-MON-YYYY')          AS OrderDate,
    EXTRACT(YEAR  FROM o.OrderDate)              AS OrderYear,
    EXTRACT(MONTH FROM o.OrderDate)              AS OrderMonth,
    TO_CHAR(o.OrderDate,'Month')                 AS MonthName,
    c.FirstName || ' ' || c.LastName            AS CustomerName,
    c.Country,
    e.FirstName || ' ' || e.LastName            AS SalesEmployee,
    p.ProductName,
    p.Category,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    ROUND(od.Quantity * od.UnitPrice
          * (1 - od.Discount), 2)               AS LineTotal,
    o.TotalAmount                                AS OrderTotal,
    o.Status
FROM Orders      o
INNER JOIN Customers   c  ON o.CustomerID  = c.CustomerID
INNER JOIN Employees   e  ON o.EmployeeID  = e.EmployeeID
INNER JOIN OrderDetails od ON o.OrderID    = od.OrderID
INNER JOIN Products    p  ON od.ProductID  = p.ProductID;

-- Usage:
-- SELECT * FROM vw_EmployeeDetails;
-- SELECT * FROM vw_SalesDashboard WHERE OrderYear = 2023;
-- SELECT * FROM vw_SalesDashboard WHERE Country = 'USA';
