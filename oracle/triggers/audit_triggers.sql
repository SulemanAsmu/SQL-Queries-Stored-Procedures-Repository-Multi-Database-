-- =============================================
-- Database:    Oracle 19c/21c
-- Author:      Suleman
-- Description: Audit and Business Rule Triggers
-- =============================================

-- -----------------------------------------------
-- Trigger 1: Audit Employee Salary Changes
-- -----------------------------------------------
CREATE OR REPLACE TRIGGER trg_Employee_Salary_Audit
    AFTER UPDATE OF Salary ON Employees
    FOR EACH ROW
    WHEN (NEW.Salary != OLD.Salary)
BEGIN
    INSERT INTO AuditLog (
        TableName, Action, RecordID,
        ChangedBy, OldValue, NewValue
    )
    VALUES (
        'EMPLOYEES',
        'SALARY CHANGE',
        :NEW.EmployeeID,
        USER,
        'Old Salary: $' || :OLD.Salary,
        'New Salary: $' || :NEW.Salary
    );
END trg_Employee_Salary_Audit;
/

-- -----------------------------------------------
-- Trigger 2: Prevent Delete of Active Employees
-- -----------------------------------------------
CREATE OR REPLACE TRIGGER trg_Prevent_Employee_Delete
    BEFORE DELETE ON Employees
    FOR EACH ROW
BEGIN
    IF :OLD.Status = 'Active' THEN
        RAISE_APPLICATION_ERROR(-20010,
            '❌ Cannot delete Active employee: '
            || :OLD.FirstName || ' ' || :OLD.LastName
            || '. Please deactivate first.');
    END IF;

    -- Log deletion of inactive employees
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, OldValue)
    VALUES (
        'EMPLOYEES', 'DELETE',
        :OLD.EmployeeID, USER,
        'Deleted: ' || :OLD.FirstName || ' '
        || :OLD.LastName || ' | ' || :OLD.JobTitle
    );
END trg_Prevent_Employee_Delete;
/

-- -----------------------------------------------
-- Trigger 3: Auto Update Order Total Amount
-- -----------------------------------------------
CREATE OR REPLACE TRIGGER trg_Update_Order_Total
    AFTER INSERT OR UPDATE OR DELETE ON OrderDetails
    FOR EACH ROW
DECLARE
    v_OrderID     NUMBER;
    v_NewTotal    NUMBER;
BEGIN
    v_OrderID := CASE
        WHEN INSERTING OR UPDATING THEN :NEW.OrderID
        ELSE :OLD.OrderID
    END;

    SELECT NVL(SUM(Quantity * UnitPrice * (1 - Discount)), 0)
    INTO v_NewTotal
    FROM OrderDetails
    WHERE OrderID = v_OrderID;

    UPDATE Orders
    SET TotalAmount = v_NewTotal
    WHERE OrderID = v_OrderID;
END trg_Update_Order_Total;
/

-- -----------------------------------------------
-- Trigger 4: Validate Stock Before Order Insert
-- -----------------------------------------------
CREATE OR REPLACE TRIGGER trg_Check_Stock
    BEFORE INSERT ON OrderDetails
    FOR EACH ROW
DECLARE
    v_Stock    NUMBER;
    v_ProdName VARCHAR2(100);
BEGIN
    SELECT StockQuantity, ProductName
    INTO v_Stock, v_ProdName
    FROM Products
    WHERE ProductID = :NEW.ProductID;

    IF :NEW.Quantity > v_Stock THEN
        RAISE_APPLICATION_ERROR(-20011,
            '❌ Insufficient stock for: ' || v_ProdName
            || '. Requested: ' || :NEW.Quantity
            || ' | Available: ' || v_Stock);
    END IF;

    -- Reduce stock
    UPDATE Products
    SET StockQuantity = StockQuantity - :NEW.Quantity
    WHERE ProductID = :NEW.ProductID;
END trg_Check_Stock;
/
