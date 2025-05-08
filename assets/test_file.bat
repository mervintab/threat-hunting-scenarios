@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
"^
$duration = 120; ^
while ($duration -ge 0) { ^
    $minutes = [math]::Floor($duration / 60); ^
    $seconds = $duration %% 60; ^
    $timeText = '{0:00}:{1:00}' -f $minutes, $seconds; ^
    Write-Host \"`rCountdown Timer: $timeText remaining...\" -ForegroundColor Cyan -NoNewline; ^
    Start-Sleep -Seconds 1; ^
    $duration--; ^
}; ^
Write-Host \"`nTime's up!\"; ^
Write-Host \"Press any key to create the EICAR file...\"; ^
[void][System.Console]::ReadKey($true); ^
$eicarContent = 'You are a child of the universe no less than the trees and the stars; you have a right to be here!'; ^
$desktopPath = [System.Environment]::GetFolderPath('Desktop'); ^
$filePath = Join-Path $desktopPath 'eicar_file.txt'; ^
Set-Content -Path $filePath -Value $eicarContent -Encoding ASCII; ^
Write-Host \"`nEICAR file created successfully at: $filePath\" ^
"
pause
