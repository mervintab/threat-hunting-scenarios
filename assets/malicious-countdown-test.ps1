# Countdown for 2 minutes
$duration = 12

while ($duration -gt 0) {
    Clear-Host
    $minutes = [math]::Floor($duration / 60)
    $seconds = $duration % 60
    Write-Host "Countdown Timer: $minutes minute(s) and $seconds second(s) remaining..." -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    $duration--
}

# After countdown
Write-Host "`nTime's up!"
Write-Host "Press any key to create the EICAR file..."
$x = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")  # wait for any key

# Write correct EICAR content directly
$eicarContent = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
Set-Content -Path (Join-Path $desktopPath 'eicar_file.txt') -Value $eicarContent -Encoding ASCII

Write-Host "EICAR file created successfully on Desktop!"
