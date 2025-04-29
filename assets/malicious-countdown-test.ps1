# Create a temporary batch file to run a 1-minute countdown timer
$timerScriptPath = "$env:TEMP\1min_timer.bat"

$scriptContent = @"
@echo off
setlocal EnableDelayedExpansion
set /a duration=60

:loop
cls
set /a minutes=!duration!/60
set /a seconds=!duration!%%60
echo Countdown Timer: !minutes! minute(s) and !seconds! second(s) remaining...
timeout /t 1 >nul
set /a duration-=1
if !duration! gtr 0 goto loop

echo Time's up!
timeout /t 3 >nul
exit
"@

Set-Content -Path $timerScriptPath -Value $scriptContent

# Run the timer in a new CMD window
Start-Process cmd.exe -ArgumentList "/c `"$timerScriptPath`""
