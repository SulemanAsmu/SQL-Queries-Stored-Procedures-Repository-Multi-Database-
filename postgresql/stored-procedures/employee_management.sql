-- =============================================
-- Database:    PostgreSQL 15
-- Author:      Suleman
-- Description: Employee Management Functions
--              PostgreSQL uses FUNCTIONS
--              with PL/pgSQL
-- =============================================

-- -----------------------------------------------
-- Function 1: Get Employee Details
-- Usage: SELECT * FROM sp_GetEmployeeDetails(1);
--        SELECT * FROM sp_GetEmployeeDetails(NULL);
-- -----------------------------------------------
CREATE OR REPLACE FUNCTION sp_GetEmployeeDetails(
    p_EmployeeID INT DEFAULT NULL
)
RETURNS TABLE (
    EmployeeID      INT,
    FullName        TEXT,
    Email           VARCHAR,
    JobTitle        VARCHAR,
    Salary          NUMERIC,
    HireDate        DATE,
    Status          VARCHAR,
    DepartmentName  VARCHAR,
    Location        VARCHAR,
    ManagerName     TEXT,
    YearsOfService  INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate if specific ID provided
    IF p_EmployeeID IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM Employees
            WHERE EmployeeID = p_EmployeeID
        ) THEN
            RAISE EXCEPTION 'Employee ID % not found', p_EmployeeID;
        END IF;
    END IF;

    RETURN QUERY
    SELECT
        e.EmployeeID,
        (e.FirstName || ' ' || e.LastName)::TEXT,
        e.Email,
        e.JobTitle,
        e.Salary,
        e.HireDate,
        e.Status,
        d.DepartmentName,
        d.Location,
        (m.FirstName || ' ' || m.LastName)::TEXT,
        DATE_PART('year', AGE(e.HireDate))::INT
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
    LEFT JOIN Employees   m ON e.ManagerID    = m.EmployeeID
    WHERE e.EmployeeID = COALESCE(p_EmployeeID, e.EmployeeID)
    ORDER BY d.DepartmentName, e.LastName;
END;
$$;

-- -----------------------------------------------
-- Function 2: Add New Employee
-- Usage: SELECT sp_AddEmployee(...);
-- -----------------------------------------------
CREATE OR REPLACE FUNCTION sp_AddEmployee(
    p_FirstName     VARCHAR,
    p_LastName      VARCHAR,
    p_Email         VARCHAR,
    p_Phone         VARCHAR,
    p_HireDate      DATE,
    p_Salary        NUMERIC,
    p_DepartmentID  INT,
    p_ManagerID     INT DEFAULT NULL,
    p_JobTitle      VARCHAR DEFAULT NULL
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_NewID INT;
BEGIN
    -- Validate Department
    IF NOT EXISTS (
        SELECT 1 FROM Departments
        WHERE DepartmentID = p_DepartmentID
    ) THEN
        RAISE EXCEPTION 'Department ID % does not exist', p_DepartmentID;
    END IF;

    -- Validate unique Email
    IF EXISTS (
        SELECT 1 FROM Employees WHERE Email = p_Email
    ) THEN
        RAISE EXCEPTION 'Email % already exists', p_Email;
    END IF;

    -- Validate Salary
    IF p_Salary <= 0 THEN
        RAISE EXCEPTION 'Salary must be greater than zero';
    END IF;

    -- Insert Employee
    INSERT INTO Employees (
        FirstName, LastName, Email, Phone,
        HireDate, Salary, DepartmentID,
        ManagerID, JobTitle, Status
    )
    VALUES (
        p_FirstName, p_LastName, p_Email, p_Phone,
        p_HireDate, p_Salary, p_DepartmentID,
        p_ManagerID, p_JobTitle, 'Active'
    )
    RETURNING EmployeeID INTO v_NewID;

    -- Audit Log
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, NewValue)
    VALUES (
        'Employees', 'INSERT', v_NewID,
        CURRENT_USER,
        'New Employee: ' || p_FirstName || ' ' || p_LastName
    );

    RAISE NOTICE '✅ Employee added. ID: %', v_NewID;
    RETURN v_NewID;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: %', SQLERRM;
END;
$$;
