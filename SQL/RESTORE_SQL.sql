
-- RESTORE
DECLARE @DatabaseName NVARCHAR(MAX) = 'SBH_UAT';
DECLARE @BackupFilePath NVARCHAR(MAX) = 'D:\Applications\SDS\Science Based Health\Backup_2017STD\v1\' + @DatabaseName + '.bak';

-- Generate data and log file paths dynamically
DECLARE @DataFilePath NVARCHAR(MAX) = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019STD\MSSQL\DATA\' + @DatabaseName + '.mdf';
DECLARE @LogFilePath NVARCHAR(MAX) = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019STD\MSSQL\DATA\' + @DatabaseName + '.ldf';

DECLARE @RestoreCommand NVARCHAR(MAX);

SET @RestoreCommand = 'RESTORE DATABASE ' + @DatabaseName + ' 
FROM DISK = ''' + @BackupFilePath + ''' 
WITH 
    MOVE ''' + @DatabaseName + '_Data'' TO ''' + @DataFilePath + ''',
    MOVE ''' + @DatabaseName + '_Log'' TO ''' + @LogFilePath + ''',
    REPLACE, RECOVERY;';

EXEC (@RestoreCommand);



-- RESORE ALL


-- Enable xp_cmdshell
--EXEC sp_configure 'show advanced options', 1;
--RECONFIGURE;
--EXEC sp_configure 'xp_cmdshell', 1;
--RECONFIGURE;
-- Drop the temporary table


DECLARE @BackupFolderPath NVARCHAR(MAX) = 'D:\Applications\SDS\Science Based Health\Backup_2017STD\v1\';
DECLARE @BackupFiles TABLE (FileName NVARCHAR(MAX));

CREATE TABLE #BackupFiles (FileName NVARCHAR(MAX));

INSERT INTO #BackupFiles (FileName)
EXEC xp_cmdshell 'dir "D:\Applications\SDS\Science Based Health\Backup_2017STD\v1\*.bak" /b';


-- Iterate through backup files
DECLARE @FileName NVARCHAR(MAX);
DECLARE @DatabaseName NVARCHAR(MAX);
DECLARE @DataFilePath NVARCHAR(MAX);
DECLARE @LogFilePath NVARCHAR(MAX);
DECLARE @RestoreCommand NVARCHAR(MAX);

DECLARE file_cursor CURSOR FOR
SELECT FileName FROM #BackupFiles;

OPEN file_cursor;
FETCH NEXT FROM file_cursor INTO @FileName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Extract database name from file name
    SET @DatabaseName = REPLACE(REPLACE(@FileName, @BackupFolderPath, ''), '.bak', '');

    -- Generate data and log file paths dynamically
    SET @DataFilePath = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019STD\MSSQL\DATA\' + @DatabaseName + '.mdf';
    SET @LogFilePath = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019STD\MSSQL\DATA\' + @DatabaseName + '.ldf';

    -- Construct restore command
    SET @RestoreCommand = 'RESTORE DATABASE ' + @DatabaseName + ' 
        FROM DISK = ''' + @BackupFolderPath + @FileName + ''' 
        WITH 
            MOVE ''' + @DatabaseName + '_Data'' TO ''' + @DataFilePath + ''',
            MOVE ''' + @DatabaseName + '_Log'' TO ''' + @LogFilePath + ''',
            REPLACE, RECOVERY;';

    -- Execute restore command
    PRINT 'Restoring database ' + @DatabaseName + '...';

	PRINT @RestoreCommand
    EXEC (@RestoreCommand);

    FETCH NEXT FROM file_cursor INTO @FileName;
END

CLOSE file_cursor;
DEALLOCATE file_cursor;