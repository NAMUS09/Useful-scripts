CREATE PROCEDURE mtbSearchDatabase
(
    @SearchStr nvarchar(100)
)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @SearchResults TABLE(TableAndColumnName nvarchar(512), ColumnValue nvarchar(max));
    DECLARE @TableName nvarchar(256), @ColumnName nvarchar(256), @TableAndColumnName nvarchar(512),
        @TableAndColumnName2 nvarchar(512), @SearchStr2 nvarchar(110);
 
    SET @TableAndColumnName = '';
    SET @SearchStr2 = QUOTENAME('%' + @SearchStr + '%','''');
 
    WHILE @TableAndColumnName IS NOT NULL
    BEGIN
        SELECT TOP 1 @TableAndColumnName = QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)+ '.' + QUOTENAME(COLUMN_NAME),
                @TableName = QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME), 
                @ColumnName = QUOTENAME(COLUMN_NAME)
            FROM INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK) 
            WHERE OBJECTPROPERTY(
                    OBJECT_ID(
                        QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)
                        ), 'IsMSShipped'
                ) = 0
                AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)+ '.' + QUOTENAME(COLUMN_NAME) > @TableAndColumnName
                AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext')
                ORDER BY QUOTENAME(TABLE_SCHEMA), QUOTENAME(TABLE_NAME), QUOTENAME(COLUMN_NAME);
 
        IF @TableAndColumnName != ISNULL(@TableAndColumnName2, '')
        BEGIN
            SET @TableAndColumnName2 = @TableAndColumnName;
 
            INSERT INTO @SearchResults
            EXEC ('SELECT ''' + @TableAndColumnName + ''', ' + @ColumnName + 
                ' FROM ' + @TableName + ' WITH (NOLOCK) ' +
                ' WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2
            );
        END
        ELSE
        BEGIN
            BREAK;
        END
    END
 
    SELECT TableAndColumnName, ColumnValue FROM @SearchResults
END
GO
