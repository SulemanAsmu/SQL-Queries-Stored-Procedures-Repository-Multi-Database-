-- =============================================
-- Database:    Oracle 19c/21c
-- Author:      Suleman
-- Description: CTEs, Subqueries & Hierarchical
--              Queries using CONNECT BY
-- =============================================

-- -----------------------------------------------
-- Query 1: CTE - Sales Summary Per Employee
-- -----------------------------------------------
WITH SalesSummary AS (
    SELECT
        e.EmployeeID,
        e.FirstName || ' ' || e.LastName   AS EmployeeName,
        e.JobTitle,
        COUNT(o.OrderID)                   AS TotalOrders,
        SUM(o.TotalAmount)                 AS TotalSales,
        AVG(o.TotalAmount)                 AS AvgOrderValue,
        MAX(o.TotalAmount)                 AS HighestOrder
    FROM Employees e
    INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
    GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.JobTitle
)
SELECT
    EmployeeName,
    JobTitle,
    TotalOrders,
    TotalSales,
    ROUND(AvgOrderValue,2)    AS AvgOrderValue,
    HighestOrder,
    RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank
FROM SalesSummary
ORDER BY SalesRank;

-- -----------------------------------------------
-- Query 2: Oracle Hierarchical Query
--          Employee Org Chart (CONNECT BY)
-- -----------------------------------------------
SELECT
    LEVEL                                        AS HierarchyLevel,
    LPAD(' ', (LEVEL-1)*4)
    || FirstName || ' ' || LastName              AS OrgChart,
    JobTitle,
    SYS_CONNECT_BY_PATH(
        FirstName || ' ' || LastName, ' → '
    )                                            AS FullPath
FROM Employees
START WITH ManagerID IS NULL
CONNECT BY PRIOR EmployeeID = ManagerID
ORDER SIBLINGS BY LastName;

-- -----------------------------------------------
-- Query 3: Employees Above Department Avg Salary
-- -----------------------------------------------
SELECT
    e.EmployeeID,
    e.FirstName || ' ' || e.LastName    AS EmployeeName,
    e.JobTitle,
    e.Salary,
    d.DepartmentName,
    ROUND(DeptAvg.AvgSalary, 2)         AS DeptAvgSalary,
    ROUND(e.Salary - DeptAvg.AvgSalary, 2) AS AboveAvgBy
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
INNER JOIN (
    SELECT DepartmentID, AVG(Salary) AS AvgSalary
    FROM Employees
    GROUP BY DepartmentID
) DeptAvg ON e.DepartmentID = DeptAvg.DepartmentID
WHERE e.Salary > DeptAvg.AvgSalary
ORDER BY d.DepartmentName, AboveAvgBy DESC;

-- -----------------------------------------------
-- Query 4: Customer Segmentation CTE
-- -----------------------------------------------
WITH CustomerOrders AS (
    SELECT
        c.CustomerID,
        c.FirstName || ' ' || c.LastName  AS CustomerName,
        c.Country,
        COUNT(o.OrderID)                  AS TotalOrders,
        NVL(SUM(o.TotalAmount), 0)        AS TotalSpent
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Country
),
CustomerSegments AS (
    SELECT
        CustomerID,
        CustomerName,
        Country,
        TotalOrders,
        TotalSpent,
        CASE
            WHEN TotalSpent >= 1000 THEN 'VIP'
            WHEN TotalSpent >= 500  THEN 'Regular'
            WHEN TotalSpent >  0   THEN 'New'
            ELSE 'Inactive'
        END AS Segment
    FROM CustomerOrders
)
SELECT
    Segment,
    COUNT(*)          AS TotalCustomers,
    SUM(TotalOrders)  AS TotalOrders,
    SUM(TotalSpent)   AS TotalRevenue,
    ROUND(AVG(TotalSpent),2) AS AvgSpent
FROM CustomerSegments
GROUP BY Segment
ORDER BY TotalRevenue DESC;
