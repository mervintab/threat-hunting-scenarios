# Create a temporary batch file to run a countdown timer
$timerScriptPath = "$env:TEMP\3min_timer.bat"

$scriptContent = @"
@echo off
setlocal EnableDelayedExpansion
set /a duration=180

:loop
cls
set /a minutes=!duration!/60
set /a seconds=!duration!%%60
echo Countdown Timer: !minutes! minute(s) and !seconds! second(s) remaining...
timeout /t 1 >nul
set /a duration-=1
if !duration! gtr 0 goto loop

echo Time's up!
pause
"@

Set-Content -Path $timerScriptPath -Value $scriptContent

# Run the timer in a new CMD window
Start-Process cmd.exe -ArgumentList "/c `"$timerScriptPath`""
