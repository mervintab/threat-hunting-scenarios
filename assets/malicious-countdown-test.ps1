# Define the path for the countdown batch file
$timerScriptPath = "$env:TEMP\2min_timer_with_pause.bat"

# Create the batch file with 2-minute countdown logic and pause for user input
$scriptContent = @"
@echo off
setlocal EnableDelayedExpansion
set /a duration=120

:loop
cls
set /a minutes=!duration!/60
set /a seconds=!duration!%%60
echo Countdown Timer: !minutes! minute(s) and !seconds! second(s) remaining...
timeout /t 1 >nul
set /a duration-=1
if !duration! gtr 0 goto loop

echo Time's up!
echo Press any key to continue...
pause >nul
exit
"@

# Save the batch file
Set-Content -Path $timerScriptPath -Value $scriptContent

# Run the timer in a new CMD window
