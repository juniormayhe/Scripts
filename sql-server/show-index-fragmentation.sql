EXEC sp_msforeachtable ' SELECT ''?'',a.index_id, name, avg_fragmentation_in_percent  
FROM sys.dm_db_index_physical_stats (DB_ID(N''Gerencial''), 
      OBJECT_ID(N''?''), NULL, NULL, NULL) AS a  
    JOIN sys.indexes AS b 
      ON a.object_id = b.object_id AND a.index_id = b.index_id;'
