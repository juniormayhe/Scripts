SELECT
  sys.columns.name AS ColumnName,
  sys.tables.name AS TableName
FROM sys.columns
JOIN sys.tables ON sys.columns.object_id = sys.tables.object_id
WHERE sys.columns.name LIKE '%DESIRED NAME%'
