--table growth: https://www.mssqltips.com/sqlservertip/2794/report-to-capture-table-growth-statistics-for-sql-server/
/****** Object:  Table [dbo].[TableSizeGrowth]    Script Date: 15/11/2017 04:29:13 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE NAME='TableSizeGrowth')
BEGIN
	CREATE TABLE [dbo].[TableSizeGrowth](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[database_name] [nvarchar](200) NULL,
		[table_schema] [nvarchar](256) NULL,
		[table_name] [nvarchar](256) NULL,
		[table_rows] [int] NULL,
		[reserved_space] [int] NULL,
		[data_space] [int] NULL,
		[index_space] [int] NULL,
		[unused_space] [int] NULL,
		[date] [datetime] NULL
	) ON [PRIMARY];
	
	ALTER TABLE [dbo].[TableSizeGrowth] ADD  CONSTRAINT [DF_TableSizeGrowth_date]  DEFAULT (dateadd(day,(0),datediff(day,(0),getdate()))) FOR [date];
	
END

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'sp_TableSizeGrowth')
                    AND type IN ( N'P', N'PC' ) ) 
BEGIN
	DROP PROCEDURE sp_TableSizeGrowth;
END

USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[sp_TableSizeGrowth]    Script Date: 15/11/2017 04:51:47 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [DBA].[dbo].[sp_TableSizeGrowth] 'Gerencial'
CREATE PROCEDURE [dbo].[sp_TableSizeGrowth] 
	@database varchar(200)
AS
BEGIN
	SET NOCOUNT ON
 
	--DECLARE VARIABLES
	DECLARE
	@max INT,
	@min INT,
	@table_name NVARCHAR(256),
	@table_schema NVARCHAR(256),
	@sql NVARCHAR(4000)
 
	--DECLARE TABLE VARIABLE
	DECLARE @table TABLE(
	id INT IDENTITY(1,1) PRIMARY KEY,
	table_name NVARCHAR(256),
	table_schema NVARCHAR(256))
 
	--CREATE TEMP TABLE THAT STORES INFORMATION FROM SP_SPACEUSED
	IF (SELECT OBJECT_ID('tempdb..#results')) IS NOT NULL
	BEGIN
		DROP TABLE #results
	END
 
	CREATE TABLE #results
	(
		[database_name] [nvarchar](200) NULL,
		[table_schema] [nvarchar](256) NULL,
		[table_name] [nvarchar](256) NULL,
		[table_rows] [int] NULL,
		[reserved_space] [nvarchar](55) NULL,
		[data_space] [nvarchar](55) NULL,
		[index_space] [nvarchar](55) NULL,
		[unused_space] [nvarchar](55) NULL
	)
	EXEC ('use ' + @database);

	INSERT @table(table_schema, table_name)
		exec('SELECT SCHEMA_NAME(SCHEMA_ID), [name] FROM ' +  @database + '.sys.tables')

		
	SELECT @min = 1, @max = (SELECT MAX(id) FROM @table)
 
	WHILE @min < @max + 1
	BEGIN
		SELECT 
			@table_name = table_name,
			@table_schema = table_schema
		FROM @table
		WHERE id = @min
   
		--DYNAMIC SQL
		SELECT @sql = 'use ' + @database +';EXEC sp_spaceused  ''[' + @table_schema + '].[' + @table_name + ']'''
  
		--INSERT RESULTS FROM SP_SPACEUSED TO TEMP TABLE
		INSERT #results(table_name, table_rows, reserved_space, data_space, index_space, unused_space)
			EXEC (@sql)
  
		--UPDATE SCHEMA NAME
		UPDATE #results
		SET [database_name] = @database, table_schema = @table_schema
		WHERE table_name = @table_name
		
		SELECT @min = @min + 1
	END
 
	--REMOVE "KB" FROM RESULTS FOR REPORTING (GRAPH) PURPOSES
	UPDATE #results SET data_space = SUBSTRING(data_space, 1, (LEN(data_space)-3))
	UPDATE #results SET reserved_space = SUBSTRING(reserved_space, 1, (LEN(reserved_space)-3))
	UPDATE #results SET index_space = SUBSTRING(index_space, 1, (LEN(index_space)-3))
	UPDATE #results SET unused_space = SUBSTRING(unused_space, 1, (LEN(unused_space)-3))
 
	--INSERT RESULTS INTO TABLESIZEGROWTH
	INSERT INTO TableSizeGrowth ([database_name], table_schema, table_name, table_rows, reserved_space, data_space, index_space, unused_space)
	SELECT * FROM #results
	
	DROP TABLE #results
END
GO
