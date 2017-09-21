--AuditoriaNegocio

DECLARE @TempTableVariable TABLE(
        element_id INT,
        sequenceNo INT,
        parent_ID INT,
        [Object_ID] INT,
        [NAME] NVARCHAR(2000),
        StringValue NVARCHAR(MAX),
        ValueType NVARCHAR(10)
    )

INSERT INTO @TempTableVariable
SELECT * FROM parseJSON('[
  { "firstName": "Gustavo", "lastName": "Jaramillo", "age": "25" },
  { "firstName": "John", "lastName": "Smith", "age": "38" },
  { "firstName": "Jane", "lastName": "Stewart", "age": "25" }
]')


--SELECT t.[sequenceNo], t2.[NAME], CAST(t2.[StringValue]  AS VARCHAR) AS [StringValue]
--FROM @TempTableVariable t
--INNER JOIN @TempTableVariable t2 on t.[sequenceNo]=t2.parent_ID
--where t2.[Object_ID] IS NULL
--GROUP BY t.[sequenceNo], t2.[NAME],t2.[StringValue]  --, t.parent_ID,t.[NAME],t.StringValue,t.ValueType  

DECLARE @totalColumnasPorRegistro INT


SELECT TOP 1 @totalColumnasPorRegistro = count(parent_ID) FROM @TempTableVariable
WHERE parent_ID IS NOT NULL AND [Object_ID] IS NULL
GROUP BY parent_ID
print @totalColumnasPorRegistro 

DECLARE @max_filas INT
SELECT @max_filas=COUNT(DISTINCT parent_ID) FROM @TempTableVariable WHERE [Object_ID] IS NULL

DECLARE @nombresColumnas AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX),
    @valoresColumnas as  NVARCHAR(MAX)

--columnas
select @nombresColumnas = 'DECLARE @TEMP TABLE(' + stuff((select ','+quotename(C.[NAME]) +' VARCHAR(MAX)'
from @TempTableVariable as C
where C.parent_ID is not null
GROUP BY C.[NAME]
for xml path('')), 1, 1, '')+');'
print @nombresColumnas 
--valores
SELECT @valoresColumnas = STUFF((SELECT  ',' + quotename(StringValue)
FROM @TempTableVariable t
WHERE t.parent_ID IS NOT NULL AND t.[Object_ID] IS NULL
GROUP BY t.parent_ID,t.[NAME],StringValue
FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'')
print @valoresColumnas

DECLARE @contador INT, @columnaActual INT, @fila INT, @totalColumnas INT
DECLARE @insert VARCHAR(MAX)
SET @contador=1
SET @columnaActual=1
SET @fila=1
SET @totalColumnas = @totalColumnasPorRegistro * @max_filas

SELECT @insert= 'INSERT INTO @TEMP VALUES ('

WHILE @contador <= @totalColumnas 
BEGIN
	DECLARE @valorColumnaActual VARCHAR(MAX)
	SET @valorColumnaActual = dbo.SplitIndex(',', @valoresColumnas, @columnaActual)
	SET @insert = @insert + @valorColumnaActual
	DECLARE @saltar bit
	SET @saltar = IIF((@totalColumnas - @columnaActual)%  @totalColumnasPorRegistro = 0,1,0)
	select @saltar ,@fila as fila, @totalColumnas as totalCols, @columnaActual as columnaActual, @contador as total, @valorColumnaActual as valor, @insert
	
	SET @contador = @contador+1
	
	IF @saltar = 1 BEGIN
		SET @fila= @fila +1
		SET @insert = @insert + ');'
		
		IF @fila <= @max_filas BEGIN
			SET @insert=@insert+'INSERT INTO @TEMP VALUES ('
		END
	END
	ELSE BEGIN
		SET @insert = @insert + ','
	END
	SET @columnaActual= @columnaActual+1
END
SET @insert = @insert +'SELECT * FROM @TEMP';
set @insert = @nombresColumnas + REPLACE(REPLACE(@insert,']',''''),'[','''')
print @insert
execute(@insert )


