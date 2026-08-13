-- =============================================
-- Database:    MySQL 8.0
-- Author:      Suleman
-- Description: Employee Management Procedures
-- =============================================

USE CompanyDB;

DELIMITER $$

-- -----------------------------------------------
-- Procedure 1: Get Employee Details
-- Usage: CALL sp_GetEmployeeDetails(1);
--        CALL sp_GetEmployeeDetails(NULL);
-- -----------------------------------------------
DROP PROCEDURE IF EXISTS sp_GetEmployeeDetails$$
CREATE PROCEDURE sp_GetEmployeeDetails(
    IN p_EmployeeID INT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    IF p_EmployeeID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count
        FROM Employees WHERE EmployeeID = p_EmployeeID;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee not found';
        END IF;
    END IF;

    SELECT
        e.EmployeeID,
        CONCAT(e.FirstName,' ',e.LastName)        AS FullName,
        e.Email,
        e.JobTitle,
        e.Salary,
        e.HireDate,
        e.Status,
        d.DepartmentName,
        d.Location,
        CONCAT(m.FirstName,' ',m.LastName)        AS ManagerName,
        TIMESTAMPDIFF(YEAR, e.HireDate, NOW())    AS YearsOfService
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
    LEFT JOIN Employees   m ON e.ManagerID    = m.EmployeeID
    WHERE e.EmployeeID = IFNULL(p_EmployeeID, e.EmployeeID)
    ORDER BY d.DepartmentName, e.LastName;
END$$

-- -----------------------------------------------
-- Procedure 2: Add New Employee
-- Usage: CALL sp_AddEmployee(...);
-- -----------------------------------------------
DROP PROCEDURE IF EXISTS sp_AddEmployee$$
CREATE PROCEDURE sp_AddEmployee(
    IN  p_FirstName     VARCHAR(50),
    IN  p_LastName      VARCHAR(50),
    IN  p_Email         VARCHAR(100),
    IN  p_Phone         VARCHAR(20),
    IN  p_HireDate      DATE,
    IN  p_Salary        DECIMAL(10,2),
    IN  p_DepartmentID  INT,
    IN  p_ManagerID     INT,
    IN  p_JobTitle      VARCHAR(100),
    OUT p_NewEmployeeID INT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validate Department
    SELECT COUNT(*) INTO v_count
    FROM Departments WHERE DepartmentID = p_DepartmentID;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department does not exist';
    END IF;

    -- Validate unique Email
    SELECT COUNT(*) INTO v_count
    FROM Employees WHERE Email = p_Email;
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists';
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
    );

    SET p_NewEmployeeID = LAST_INSERT_ID();

    -- Audit Log
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, NewValue)
    VALUES (
        'Employees', 'INSERT', p_NewEmployeeID,
        USER(),
        CONCAT('New Employee: ', p_FirstName, ' ', p_LastName)
    );

    COMMIT;
    SELECT CONCAT('✅ Employee added. ID: ', p_NewEmployeeID) AS Result;
END$$

DELIMITER ;
