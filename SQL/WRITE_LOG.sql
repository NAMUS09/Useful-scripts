SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[WRITELOG] @loglevel nvarchar(30), @logcontext nvarchar(30), @logmessage nvarchar(1000) 
AS
BEGIN
    SET NOCOUNT ON;
    declare
    @base_path as nvarchar(1000) = 'D:\',
    @filename as nvarchar(1000) = 'InsertShippingByWeightByTotalRecord',
    @currdate as nvarchar(24),    
    @shortdate as nvarchar(24),
    @cmdtxt as nvarchar(255)
    
    select @currdate = CONVERT(NVARCHAR(24),GETDATE(),120);
    select @shortdate = CONVERT(NVARCHAR(24),GETDATE(),112);

  
  select @cmdtxt = 'echo ' + @currdate + ' - [' + @loglevel + '] ' + 
@logcontext + ' - ' + @logmessage +' >> ' + @base_path + @filename
 + '_' + @shortdate + '.log';
    exec master..xp_cmdshell @cmdtxt    
END

/*
 
- Before using it you have to enable xp_cmdshell, to do that execute the following query:

	EXEC sp_configure 'show advanced options', 1
	GO
	RECONFIGURE
	GO
	EXEC sp_configure 'xp_cmdshell', 1
	GO
	RECONFIGURE
	GO
*/