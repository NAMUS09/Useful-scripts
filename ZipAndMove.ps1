# Define directories
$tempBackupDir = "E:\ISV_RETAIL\DB_Temp"
$archiveDir = "E:\ISV_RETAIL\WEEKLY_BACKUP"

# Get the current date in the format YYYY-MM-DD
$currentDate = Get-Date -Format "yyyy-MM-dd"

# Define the zip file name with the current date
$zipFileName = "Backups_Nop_Weekly_$currentDate.zip"

# Create a zip file from the temp backup directory
Compress-Archive -Path "$tempBackupDir\*" -DestinationPath "$archiveDir\$zipFileName"

# Remove the temporary backup directory itself
Remove-Item -Path $tempBackupDir -Recurse -Force
