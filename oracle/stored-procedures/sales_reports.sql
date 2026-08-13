-- =============================================
-- Database:    Oracle 19c/21c
-- Author:      Suleman
-- Description: Sales Report Procedures (PL/SQL)
-- =============================================

-- -----------------------------------------------
-- Procedure 1: Monthly Sales Report
-- Usage: EXEC sp_MonthlySalesReport(2023, 1);
-- -----------------------------------------------
CREATE OR REPLACE PROCEDURE sp_MonthlySalesReport (
    p_Year  IN NUMBER DEFAULT NULL,
    p_Month IN NUMBER DEFAULT NULL
)
AS
    v_Year   NUMBER := NVL(p_Year,  TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')));
    v_Month  NUMBER := NVL(p_Month, TO_NUMBER(TO_CHAR(SYSDATE,'MM')));
    v_Total  NUMBER;
    v_Count  NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================');
    DBMS_OUTPUT.PUT_LINE('MONTHLY SALES REPORT');
    DBMS_OUTPUT.PUT_LINE('Period: '
        || TO_CHAR(TO_DATE(v_Month||'-'||v_Year,'MM-YYYY'),'Month YYYY'));
    DBMS_OUTPUT.PUT_LINE('==============================');

    SELECT
        COUNT(*),
        NVL(SUM(TotalAmount),0)
    INTO v_Count, v_Total
    FROM Orders
    WHERE EXTRACT(YEAR  FROM OrderDate) = v_Year
      AND EXTRACT(MONTH FROM OrderDate) = v_Month;

    DBMS_OUTPUT.PUT_LINE('Total Orders:  ' || v_Count);
    DBMS_OUTPUT.PUT_LINE('Total Revenue: $' || v_Total);
    DBMS_OUTPUT.PUT_LINE('------------------------------');

    -- Print each order
    FOR rec IN (
        SELECT
            o.OrderID,
            TO_CHAR(o.OrderDate,'DD-MON-YYYY')  AS OrderDate,
            c.FirstName || ' ' || c.LastName    AS CustomerName,
            e.FirstName || ' ' || e.LastName    AS SalesRep,
            o.TotalAmount,
            o.Status
        FROM Orders o
        INNER JOIN Customers c ON o.CustomerID = c.CustomerID
        INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID
        WHERE EXTRACT(YEAR  FROM o.OrderDate) = v_Year
          AND EXTRACT(MONTH FROM o.OrderDate) = v_Month
        ORDER BY o.TotalAmount DESC
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Order #' || rec.OrderID ||
            ' | ' || rec.CustomerName ||
            ' | $'  || rec.TotalAmount ||
            ' | '   || rec.Status
        );
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
        RAISE;
END sp_MonthlySalesReport;
/
