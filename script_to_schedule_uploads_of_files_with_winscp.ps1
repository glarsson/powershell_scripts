# Simple script to schedule a task to upload files using WinSCP, log what happened, archive them and then prune old files.
# Could be easier and more eloquent ways to do this but this works.
# gerry.larsson@gmail.com / 2020

# Initial variables
$sftp_username = "***REMOVED***"
$sftp_password = "***REMOVED***"
$sftp_host = "***REMOVED***"
$sftp_hostkey = "***REMOVED***"

$sourceFolder = "C:\FTP_OUTGOING\"
$archiveFolder = "C:\FTP_OUTGOING\archive"
$winscpScript = "c:\temp\temp_winscp_upload_script.txt"
$winscpBinary = "C:\Program Files (x86)\WinSCP\WinSCP.exe"
$todaysDateAndTime = get-date -format yyyy-MM-ddTHH-mm-ss-ff
$winscpLogFile = "C:\temp\FILENAME_HERE_${todaysDateAndTime}.txt"

# Generate WinSCP script
Add-Content $winscpScript "option batch on"
Add-Content $winscpScript "option confirm off"
Add-Content $winscpScript "open sftp://${sftp_username}:${sftp_password}@${sftp_host}/ -hostkey=${sftp_hostkey}"
Add-Content $winscpScript "option transfer binary"
$sourceFiles = Get-ChildItem -Path $sourceFolder | Where-Object { ! $_.PSIsContainer }
foreach ($file in $sourceFiles.fullname) {
    Add-Content $winscpScript "put ${file} /"
}
Add-Content $winscpScript "close"
Add-Content $winscpScript "exit"

# Execute WinSCP script
if ($sourceFiles) {
    Start-Process -NoNewWindow -FilePath ${winscpBinary} -ArgumentList "/log=${winscpLogFile} /ini=nul /script=${winscpScript}" -Wait
}
else {
    Add-Content $winscpLogFile "Found no files to transfer."
}

# Archive uploaded files
foreach ($file in $sourceFiles.fullname) {
    Move-Item -Path $file -Destination $archiveFolder -Force
}

# Delete archived files older than 30 days and clean up last temporary script
Get-ChildItem -Path $archiveFolder | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $fileAgeLimit } | Remove-Item
Remove-Item $winscpScript