if object_id('tempdb..##INDICES') is not null
    drop table ##INDICES

CREATE TABLE ##INDICES (tabla VARCHAR(500), indice varchar(500), id_indice int, fragmentacion decimal(15,13))
GO
INSERT INTO ##INDICES (tabla, indice, id_indice, fragmentacion)
	exec sp_msforeachtable ' SELECT ''?'' as tabla,name as indice,a.index_id as id_indice, avg_fragmentation_in_percent as fragmentacion
FROM sys.dm_db_index_physical_stats (DB_ID(N''Gerencial''), 
      OBJECT_ID(N''?''), NULL, NULL, NULL) AS a  
    JOIN sys.indexes AS b 
      ON a.object_id = b.object_id AND a.index_id = b.index_id;'

DECLARE @tabla VARCHAR(500), @indice varchar(500), @id_indice int, @fragmentacion decimal(15,13)
DECLARE @SQL NVARCHAR(4000)

DECLARE CUR CURSOR FOR
	SELECT tabla, indice, id_indice, fragmentacion FROM ##INDICES

OPEN CUR

FETCH NEXT FROM CUR INTO @tabla, @indice, @id_indice,@fragmentacion

WHILE @@FETCH_STATUS = 0
  BEGIN
	IF @fragmentacion > 30 BEGIN
		PRINT 'Ejecutando ALTER INDEX ' + cast( @indice as varchar(500)) + ' ON '+@tabla+' REBUILD;'
		SET @SQL = 'EXEC (''ALTER INDEX [' + cast(@indice as varchar(500)) + '] ON '+@tabla+' REBUILD;'')';
	END 
	ELSE BEGIN
		PRINT 'Ejecutando ALTER INDEX ' + cast( @indice as varchar(500)) + ' ON '+@tabla+' REORGANIZE;'
		SET @SQL = 'EXEC (''ALTER INDEX [' + cast(@indice as varchar(500)) + '] ON '+@tabla+' REORGANIZE;'')';
	END
		
      --PRINT @SQL
      EXEC Sp_executesql @SQL

      FETCH NEXT FROM CUR INTO @tabla, @indice,@id_indice, @fragmentacion
  END

CLOSE CUR

DEALLOCATE CUR 

exec sp_msforeachtable ' SELECT ''?'',a.index_id, name, avg_fragmentation_in_percent  
FROM sys.dm_db_index_physical_stats (DB_ID(N''Gerencial''), 
      OBJECT_ID(N''?''), NULL, NULL, NULL) AS a  
    JOIN sys.indexes AS b 
      ON a.object_id = b.object_id AND a.index_id = b.index_id;'
