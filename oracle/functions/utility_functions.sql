-- =============================================
-- Database:    Oracle 19c/21c
-- Author:      Suleman
-- Description: Reusable PL/SQL Functions
-- =============================================

-- -----------------------------------------------
-- Function 1: Get Employee Full Name
-- Usage: SELECT dbo.fn_GetEmpName(1) FROM DUAL;
-- -----------------------------------------------
CREATE OR REPLACE FUNCTION fn_GetEmpName (
    p_EmployeeID IN NUMBER
)
RETURN VARCHAR2
AS
    v_FullName VARCHAR2(101);
BEGIN
    SELECT FirstName || ' ' || LastName
    INTO v_FullName
    FROM Employees
    WHERE EmployeeID = p_EmployeeID;

    RETURN v_FullName;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Unknown';
END fn_GetEmpName;
/

-- -----------------------------------------------
-- Function 2: Calculate Years of Service
-- Usage: SELECT fn_YearsOfService(DATE '2018-01-01') FROM DUAL;
-- -----------------------------------------------
CREATE OR REPLACE FUNCTION fn_YearsOfService (
    p_HireDate IN DATE
)
RETURN NUMBER
AS
BEGIN
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, p_HireDate) / 12);
END fn_YearsOfService;
/

-- -----------------------------------------------
-- Function 3: Get Department Total Salary
-- Usage: SELECT fn_DeptTotalSalary(1) FROM DUAL;
-- -----------------------------------------------
CREATE OR REPLACE FUNCTION fn_DeptTotalSalary (
    p_DepartmentID IN NUMBER
)
RETURN NUMBER
AS
    v_Total NUMBER;
BEGIN
    SELECT NVL(SUM(Salary), 0)
    INTO v_Total
    FROM Employees
    WHERE DepartmentID = p_DepartmentID;

    RETURN v_Total;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_DeptTotalSalary;
/
