# Countdown for 2 minutes (120 seconds)
$duration = 120

while ($duration -ge 0) {
    $minutes = [math]::Floor($duration / 60)
    $seconds = $duration % 60

    $timeText = "{0:00}:{1:00}" -f $minutes, $seconds
    Write-Host "`rCountdown Timer: $timeText remaining..." -ForegroundColor Cyan -NoNewline

    Start-Sleep -Seconds 1
    $duration--
}
# After countdown
Write-Host "`nTime's up!"
Write-Host "Press any key to create the EICAR file..."
[void][System.Console]::ReadKey($true)  # waits for any key without error

# Write correct EICAR content directly
$eicarContent = 'This is a test file....'
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$filePath = Join-Path $desktopPath 'eicar_file.txt'
Set-Content -Path $filePath -Value $eicarContent -Encoding ASCII

Write-Host "`nEICAR file created successfully at: $filePath"
