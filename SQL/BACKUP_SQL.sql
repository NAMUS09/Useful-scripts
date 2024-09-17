


USE master;
GO

DECLARE @DatabaseName NVARCHAR(100);
DECLARE @BackupName NVARCHAR(100);
SET @DatabaseName = 'SBH_WebOP';
SET @BackupName = 'Full Backup of ' + @DatabaseName;

-- Backup Database
DECLARE @BackupPath nVARCHAR(100) = 'D:\Applications\SDS\Science Based Health\Backup_2017STD\' + @DatabaseName + '.bak';
BACKUP DATABASE @DatabaseName
TO DISK = @BackupPath
WITH FORMAT,
     MEDIANAME = @DatabaseName,
     NAME = @BackupName
GO


USE master;
GO

DECLARE @DatabaseName NVARCHAR(100);
DECLARE @BackupName NVARCHAR(100);
DECLARE @BackupPath NVARCHAR(100);
DECLARE @SQL NVARCHAR(MAX);

-- Cursor declaration
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');

-- Open the cursor
OPEN db_cursor;

-- Fetch the first database name
FETCH NEXT FROM db_cursor INTO @DatabaseName;

-- Start looping through each database
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Set backup name and path
    SET @BackupName = 'Full Backup of ' + @DatabaseName;
    SET @BackupPath = 'D:\Applications\SDS\Science Based Health\Backup_2017STD\v1\' + @DatabaseName + '.bak';

    -- Build dynamic SQL for backup
    SET @SQL = 'BACKUP DATABASE ' + QUOTENAME(@DatabaseName) + ' TO DISK = ''' + @BackupPath + ''' WITH FORMAT, MEDIANAME = ''' + @DatabaseName + ''', NAME = ''' + @BackupName + '''';

    -- Execute the backup command
    EXEC sp_executesql @SQL;

    -- Fetch the next database name
    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END

-- Close and deallocate the cursor
CLOSE db_cursor;
DEALLOCATE db_cursor;

