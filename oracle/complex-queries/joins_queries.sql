-- =============================================
-- Database:    Oracle 19c/21c
-- Author:      Suleman
-- Description: Advanced JOIN Queries
-- =============================================

-- -----------------------------------------------
-- Query 1: Employee Full Details with Department
-- -----------------------------------------------
SELECT
    e.EmployeeID,
    e.FirstName || ' ' || e.LastName     AS FullName,
    e.JobTitle,
    e.Salary,
    e.HireDate,
    d.DepartmentName,
    d.Location
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentName, e.LastName;

-- -----------------------------------------------
-- Query 2: Employee and Manager (SELF JOIN)
-- -----------------------------------------------
SELECT
    e.EmployeeID,
    e.FirstName || ' ' || e.LastName     AS EmployeeName,
    e.JobTitle,
    m.FirstName || ' ' || m.LastName     AS ManagerName,
    m.JobTitle                           AS ManagerTitle
FROM Employees e
LEFT JOIN Employees m
    ON e.ManagerID = m.EmployeeID
ORDER BY ManagerName NULLS LAST, EmployeeName;

-- -----------------------------------------------
-- Query 3: Orders with Customer & Employee
-- -----------------------------------------------
SELECT
    o.OrderID,
    TO_CHAR(o.OrderDate,'DD-MON-YYYY')   AS OrderDate,
    c.FirstName || ' ' || c.LastName     AS CustomerName,
    c.Country,
    e.FirstName || ' ' || e.LastName     AS SalesEmployee,
    o.TotalAmount,
    o.Status
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID
ORDER BY o.OrderDate DESC;

-- -----------------------------------------------
-- Query 4: Department Budget vs Salary Cost
-- -----------------------------------------------
SELECT
    d.DepartmentName,
    d.Location,
    d.Budget,
    COUNT(e.EmployeeID)                  AS TotalEmployees,
    NVL(SUM(e.Salary),0)                 AS TotalSalaries,
    d.Budget - NVL(SUM(e.Salary),0)      AS RemainingBudget,
    ROUND(NVL(SUM(e.Salary),0)
          / d.Budget * 100, 2)           AS BudgetUsedPct
FROM Departments d
LEFT JOIN Employees e
    ON d.DepartmentID = e.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName,
    d.Location,
    d.Budget
ORDER BY BudgetUsedPct DESC;
