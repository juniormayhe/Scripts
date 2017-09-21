--declare @teste varchar(max)
--declare @total int, @columna int, @fila int
--set @total=1
--set @columna=1
--set @fila=1
--while @total < 7
--begin
--  select @fila as fila, @columna as columna, @total as total, dbo.SplitIndex(',', '[1],[Nombre],[Apellidos],[2],[Nombre2],[Apellidos2]', @columna)
--  set @total = @total +1
--  set @columna= @columna+1
--  if @columna = 4 begin
--	set @fila= @fila +1
--  end
--end


DECLARE @TempTableVariable TABLE(
        element_id INT,
        sequenceNo INT,
        parent_ID INT,
        [Object_ID] INT,
        [NAME] NVARCHAR(2000),
        StringValue NVARCHAR(MAX),
        ValueType NVARCHAR(10)
    )
    -- Parse JSON string into a temp table
INSERT INTO @TempTableVariable
Select * from parseJSON('[
  { "firstName": "John", "lastName": "Smith", "age": 38 },
  { "firstName": "Jane", "lastName": "Stewart", "age": 25 }
]')
select t.[sequenceNo], t2.[NAME],t2.[StringValue] 
from @TempTableVariable t
inner join @TempTableVariable t2 on t.[sequenceNo]=t2.parent_ID
group by t.[sequenceNo], t2.[NAME],t2.[StringValue]  --, t.parent_ID,t.[NAME],t.StringValue,t.ValueType  
declare @totalColumnas int

select top 1 @totalColumnas = count(parent_ID) from @TempTableVariable
where parent_ID is not null and [Object_ID] is null
group by parent_ID
--select @totalColumnas as totalColumnas

DECLARE @colsUnpivot AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX),
    @colsPivot as  NVARCHAR(MAX)

--columnas
select @colsUnpivot = 'DECLARE @TEMP TABLE(' + stuff((select ','+quotename(C.[NAME]) +' VARCHAR(MAX)'
from @TempTableVariable as C
where C.parent_ID is not null
GROUP BY C.[NAME]
for xml path('')), 1, 1, '')+');'

--select @colsUnpivot 

--EXEC(@colsUnpivot)



--valores
select @colsPivot = STUFF((SELECT  ',' + quotename(StringValue)
from @TempTableVariable t
where t.parent_ID is not null and t.[Object_ID] is null
GROUP BY t.parent_ID,t.[NAME],StringValue
FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'')

--select @colsPivot

declare @totalFilas int, @columna int, @fila int
declare @insert varchar(max)
set @totalFilas=1
set @columna=1
set @fila=1
select @insert= 'INSERT INTO @TEMP VALUES ('
--select @insert as ins

while @totalFilas < 7
begin
	declare @valorColumnaActual varchar(max)
	set @valorColumnaActual = dbo.SplitIndex(',', @colsPivot, @columna)
  set @insert = @insert + @valorColumnaActual
  --select @fila as fila, @columna as columna, @totalFilas as total, @valorColumnaActual as valor
  set @totalFilas = @totalFilas+1
  set @columna= @columna+1
  if @columna = @totalColumnas+1 OR @columna = 7 begin
	set @fila= @fila +1
	set @insert = @insert + ');'
	
	--select @insert 
	--execute(@insert)
	--execute insert and reset insert
	if @fila < 3 begin
		set @insert=@insert+'INSERT INTO @TEMP VALUES ('
		--select @fila as fila, @totalColumnas as totalCol, @columna as col
	end
  end
  else begin
	set @insert = @insert + ','
  end
  
end
SET @insert = @insert +'SELECT * FROM @TEMP';
set @insert = @colsUnpivot + REPLACE(REPLACE(@insert,']',''''),'[','''')
--select @insert
execute(@insert )


