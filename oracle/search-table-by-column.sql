
SELECT table_name, column_name 
FROM dba_tab_columns 
WHERE column_name LIKE '%DESIRED NAME%' 
AND owner = 'DB OWNER NAME' 
ORDER BY 1;
