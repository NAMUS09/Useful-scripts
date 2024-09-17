SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--DROP PROC IF EXISTS InsertGenerator
GO

CREATE PROC InsertGenerator
(
    @tableName NVARCHAR(100), 
    @whereCondition NVARCHAR(MAX) = ''
) 
AS
BEGIN
    -- Declare a cursor to retrieve column specific information for the specified table
    DECLARE cursCol CURSOR FAST_FORWARD FOR 
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_name = @tableName

    OPEN cursCol

    DECLARE @string NVARCHAR(3000) -- For storing the first half of the INSERT statement
    DECLARE @stringData NVARCHAR(3000) -- For storing the data (VALUES) part of the statement
    DECLARE @dataType NVARCHAR(1000) -- Data types returned for respective columns
    DECLARE @colName NVARCHAR(50)

    SET @string = 'INSERT INTO ' + @tableName + '('
    SET @stringData = ''

    FETCH NEXT FROM cursCol INTO @colName, @dataType

    -- If no columns are found, exit the procedure
    IF @@FETCH_STATUS <> 0
    BEGIN
        PRINT 'Table ' + @tableName + ' not found, processing skipped.'
        CLOSE cursCol
        DEALLOCATE cursCol
        RETURN
    END

    -- Loop through columns to build the INSERT statement dynamically
    WHILE @@FETCH_STATUS=0
	BEGIN
	IF @dataType in ('varchar','char','nchar','nvarchar')
	BEGIN
		--SET @stringData=@stringData+'''''''''+isnull('+@colName+','''')+'''''',''+'
		SET @stringData=@stringData+''''+'''+isnull('''''+'''''+'+@colName+'+'''''+''''',''NULL'')+'',''+'
	END
	ELSE
	if @dataType in ('text','ntext') --if the datatype is text or something else 
	BEGIN
		SET @stringData=@stringData+'''''''''+isnull(cast('+@colName+' as varchar(2000)),'''')+'''''',''+'
	END
	ELSE
	IF @dataType = 'money' --because money doesn't get converted from varchar implicitly
	BEGIN
		SET @stringData=@stringData+'''convert(money,''''''+isnull(cast('+@colName+' as varchar(200)),''0.0000'')+''''''),''+'
	END
	ELSE 
	IF @dataType='datetime'
	BEGIN
		--SET @stringData=@stringData+'''convert(datetime,''''''+isnull(cast('+@colName+' as varchar(200)),''0'')+''''''),''+'
		--SELECT 'INSERT Authorizations(StatusDate) VALUES('+'convert(datetime,'+isnull(''''+convert(varchar(200),StatusDate,121)+'''','NULL')+',121),)' FROM Authorizations
		--SET @stringData=@stringData+'''convert(money,''''''+isnull(cast('+@colName+' as varchar(200)),''0.0000'')+''''''),''+'
		SET @stringData=@stringData+'''convert(datetime,'+'''+isnull('''''+'''''+convert(varchar(200),'+@colName+',121)+'''''+''''',''NULL'')+'',121),''+'
	  --                             'convert(datetime,'+isnull(''''+convert(varchar(200),StatusDate,121)+'''','NULL')+',121),)' FROM Authorizations
	END
	ELSE 
	IF @dataType='image' 
	BEGIN
		SET @stringData=@stringData+'''''''''+isnull(cast(convert(varbinary,'+@colName+') as varchar(6)),''0'')+'''''',''+'
	END
	ELSE --presuming the data type is int,bit,numeric,decimal 
	BEGIN
		--SET @stringData=@stringData+'''''''''+isnull(cast('+@colName+' as varchar(200)),''0'')+'''''',''+'
		--SET @stringData=@stringData+'''convert(datetime,'+'''+isnull('''''+'''''+convert(varchar(200),'+@colName+',121)+'''''+''''',''NULL'')+'',121),''+'
		SET @stringData=@stringData+''''+'''+isnull('''''+'''''+convert(varchar(200),'+@colName+')+'''''+''''',''NULL'')+'',''+'
	END

	SET @string=@string+@colName+','

	FETCH NEXT FROM cursCol INTO @colName,@dataType
	END

    -- Declare the query string
    DECLARE @Query NVARCHAR(4000)

    -- Add the WHERE condition dynamically if it exists
    IF @whereCondition <> ''
    BEGIN
        SET @whereCondition = ' WHERE ' + @whereCondition
    END

    -- Build the final query with dynamic column values and WHERE condition
    SET @query = 'SELECT ''' + SUBSTRING(@string, 0, LEN(@string)) + ') VALUES('' + ' 
        + SUBSTRING(@stringData, 0, LEN(@stringData) - 2) + ''' + '')'' FROM ' + @tableName + @whereCondition

    -- Execute the dynamic SQL to generate the INSERT statements
    EXEC sp_executesql @query

    -- Close and deallocate the cursor
    CLOSE cursCol
    DEALLOCATE cursCol
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--EXEC InsertGenerator
--@tableName='Topic', @whereCondition='IncludeInCustomSection = 1 AND CustomSectionId <> 0';

