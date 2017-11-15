
IF OBJECT_ID('tempdb..##DUPLICADOS') IS NOT NULL
    DROP TABLE ##DUPLICADOS

CREATE TABLE ##DUPLICADOS (tabla VARCHAR(500), campo varchar(500), tipo varchar(20))
GO
INSERT INTO ##DUPLICADOS (tabla, campo, tipo)
	EXEC sp_msforeachtable 'SELECT ''?'',c.[name], t.[name] FROM sys.columns c JOIN sys.types AS t ON c.user_type_id=t.user_type_id WHERE c.object_id = OBJECT_ID(''?'');'

UPDATE ##DUPLICADOS SET
campo = 'CAST( ' + campo + ' AS VARCHAR(MAX)) '
WHERE tipo IN ('ntext', 'text')


UPDATE ##DUPLICADOS SET
campo = 'CAST(CAST( ' + campo + ' AS VARBINARY(MAX)) AS VARCHAR(MAX)) '
WHERE tipo = 'image'


DECLARE @sql varchar(max) = '', @tabla VARCHAR(500), @campo varchar(500), @tipo varchar(20)

DECLARE cur CURSOR FOR SELECT tabla,campo,tipo FROM ##DUPLICADOS
OPEN cur

FETCH NEXT FROM cur INTO @tabla,@campo,@tipo 

WHILE @@FETCH_STATUS = 0 BEGIN
	PRINT 'Procesando ' + @tabla
	DECLARE @campos VARCHAR(4000)=''
	SELECT @campos = COALESCE(@campos + ',', '') + campo FROM ##DUPLICADOS WHERE tabla = @tabla;
	SET @campos  = SUBSTRING(@campos,2,LEN(@campos)) 
	
	SET @sql = 'DECLARE @total int=0;
	SELECT TOP 1 @total=COUNT(*) FROM ' + @tabla +'
	GROUP BY ' + @campos + '
	HAVING COUNT(*) > 5; 
	IF @total>0 BEGIN 
		SELECT ''REGISTROS DUPLICADOS EN ' + @tabla +''' 
		SELECT ' + @campos + ',COUNT(*) AS TOTAL FROM ' + @tabla +'
		GROUP BY ' + @campos + '
		HAVING COUNT(*) > 5; 
	END 
	ELSE 
		PRINT '' ''; '
	
	exec(@sql)
	delete from ##DUPLICADOS WHERE tabla = @tabla
    
    FETCH NEXT FROM cur INTO @tabla,@campo,@tipo 
END

CLOSE cur    
DEALLOCATE cur
