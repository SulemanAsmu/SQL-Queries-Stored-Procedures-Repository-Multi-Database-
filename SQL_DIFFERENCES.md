# SQL Syntax Differences Across Databases

| Feature            | Oracle          | MySQL           | PostgreSQL      | MariaDB         | MSSQL           |
|-------------------|-----------------|-----------------|-----------------|-----------------|-----------------|
| Auto Increment    | SEQUENCE        | AUTO_INCREMENT  | SERIAL          | AUTO_INCREMENT  | IDENTITY(1,1)   |
| String Join       | \|\|            | CONCAT()        | \|\|            | CONCAT()        | +               |
| Current Date      | SYSDATE         | NOW()           | NOW()           | NOW()           | GETDATE()       |
| If Null           | NVL()           | IFNULL()        | COALESCE()      | IFNULL()        | ISNULL()        |
| Limit Rows        | ROWNUM/FETCH    | LIMIT           | LIMIT           | LIMIT           | TOP             |
| Stored Proc Lang  | PL/SQL          | SQL/PSM         | PL/pgSQL        | SQL/PSM         | T-SQL           |
| Date Difference   | MONTHS_BETWEEN  | TIMESTAMPDIFF   | AGE()           | TIMESTAMPDIFF   | DATEDIFF        |
| String to Date    | TO_DATE()       | STR_TO_DATE()   | TO_DATE()       | STR_TO_DATE()   | CONVERT()       |
