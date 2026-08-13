-- =============================================
-- Database:    Oracle 19c/21c
-- Author:      Suleman
-- Description: Employee Management PL/SQL
--              Stored Procedures
-- =============================================

-- -----------------------------------------------
-- Procedure 1: Get Employee Details
-- Usage: EXEC sp_GetEmployeeDetails(1);
--        EXEC sp_GetEmployeeDetails(NULL); -- All
-- -----------------------------------------------
CREATE OR REPLACE PROCEDURE sp_GetEmployeeDetails (
    p_EmployeeID IN Employees.EmployeeID%TYPE DEFAULT NULL
)
AS
    v_count NUMBER;
BEGIN
    IF p_EmployeeID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count
        FROM Employees
        WHERE EmployeeID = p_EmployeeID;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Employee ID ' || p_EmployeeID || ' not found.');
        END IF;
    END IF;

    FOR rec IN (
        SELECT
            e.EmployeeID,
            e.FirstName || ' ' || e.LastName         AS FullName,
            e.Email,
            e.JobTitle,
            e.Salary,
            TO_CHAR(e.HireDate, 'DD-MON-YYYY')       AS HireDate,
            e.Status,
            d.DepartmentName,
            d.Location,
            m.FirstName || ' ' || m.LastName         AS ManagerName,
            TRUNC(MONTHS_BETWEEN(SYSDATE,e.HireDate)/12) AS YearsOfService
        FROM Employees e
        LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
        LEFT JOIN Employees   m ON e.ManagerID    = m.EmployeeID
        WHERE e.EmployeeID = NVL(p_EmployeeID, e.EmployeeID)
        ORDER BY d.DepartmentName, e.LastName
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('========================');
        DBMS_OUTPUT.PUT_LINE('ID:         ' || rec.EmployeeID);
        DBMS_OUTPUT.PUT_LINE('Name:       ' || rec.FullName);
        DBMS_OUTPUT.PUT_LINE('Title:      ' || rec.JobTitle);
        DBMS_OUTPUT.PUT_LINE('Dept:       ' || rec.DepartmentName);
        DBMS_OUTPUT.PUT_LINE('Salary:     ' || rec.Salary);
        DBMS_OUTPUT.PUT_LINE('Manager:    ' || NVL(rec.ManagerName,'No Manager'));
        DBMS_OUTPUT.PUT_LINE('Experience: ' || rec.YearsOfService || ' years');
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END sp_GetEmployeeDetails;
/

-- -----------------------------------------------
-- Procedure 2: Add New Employee
-- -----------------------------------------------
CREATE OR REPLACE PROCEDURE sp_AddEmployee (
    p_FirstName     IN Employees.FirstName%TYPE,
    p_LastName      IN Employees.LastName%TYPE,
    p_Email         IN Employees.Email%TYPE,
    p_Phone         IN Employees.Phone%TYPE,
    p_HireDate      IN Employees.HireDate%TYPE,
    p_Salary        IN Employees.Salary%TYPE,
    p_DepartmentID  IN Employees.DepartmentID%TYPE,
    p_ManagerID     IN Employees.ManagerID%TYPE DEFAULT NULL,
    p_JobTitle      IN Employees.JobTitle%TYPE,
    p_NewEmployeeID OUT Employees.EmployeeID%TYPE
)
AS
    v_count     NUMBER;
    v_NewID     NUMBER;
BEGIN
    -- Validate Department
    SELECT COUNT(*) INTO v_count
    FROM Departments
    WHERE DepartmentID = p_DepartmentID;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Department ID ' || p_DepartmentID || ' does not exist.');
    END IF;

    -- Validate unique Email
    SELECT COUNT(*) INTO v_count
    FROM Employees
    WHERE Email = p_Email;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003,
            'Email ' || p_Email || ' already exists.');
    END IF;

    -- Validate Salary
    IF p_Salary <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004,
            'Salary must be greater than zero.');
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
    RETURNING EmployeeID INTO p_NewEmployeeID;

    -- Audit Log
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, NewValue)
    VALUES (
        'EMPLOYEES', 'INSERT', p_NewEmployeeID,
        USER,
        'New Employee: ' || p_FirstName || ' ' || p_LastName
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Employee added. ID: ' || p_NewEmployeeID);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
        RAISE;
END sp_AddEmployee;
/

-- -----------------------------------------------
-- Procedure 3: Update Employee Salary with Audit
-- -----------------------------------------------
CREATE OR REPLACE PROCEDURE sp_UpdateEmployeeSalary (
    p_EmployeeID   IN Employees.EmployeeID%TYPE,
    p_NewSalary    IN Employees.Salary%TYPE,
    p_Reason       IN VARCHAR2 DEFAULT 'Annual Review'
)
AS
    v_OldSalary    Employees.Salary%TYPE;
    v_EmpName      VARCHAR2(101);
    v_count        NUMBER;
BEGIN
    -- Validate employee exists
    SELECT COUNT(*) INTO v_count
    FROM Employees
    WHERE EmployeeID = p_EmployeeID;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Employee ID ' || p_EmployeeID || ' not found.');
    END IF;

    -- Get current salary and name
    SELECT Salary,
           FirstName || ' ' || LastName
    INTO v_OldSalary, v_EmpName
    FROM Employees
    WHERE EmployeeID = p_EmployeeID;

    -- Validate new salary
    IF p_NewSalary <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004,
            'Salary must be greater than zero.');
    END IF;

    -- Update salary
    UPDATE Employees
    SET Salary = p_NewSalary
    WHERE EmployeeID = p_EmployeeID;

    -- Audit Log
    INSERT INTO AuditLog (
        TableName, Action, RecordID,
        ChangedBy, OldValue, NewValue
    )
    VALUES (
        'EMPLOYEES', 'SALARY UPDATE', p_EmployeeID,
        USER,
        'Old Salary: ' || v_OldSalary,
        'New Salary: ' || p_NewSalary || ' | Reason: ' || p_Reason
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ ' || v_EmpName ||
        ' salary updated from ' || v_OldSalary ||
        ' to ' || p_NewSalary);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
        RAISE;
END sp_UpdateEmployeeSalary;
/
