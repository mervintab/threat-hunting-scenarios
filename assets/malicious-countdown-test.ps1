# Define the path for the countdown batch file
$timerScriptPath = "$env:TEMP\2min_timer_with_eicar.bat"

# Create the batch file with countdown logic, key press pause, and EICAR file creation
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
echo X5O! P%%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$ H+H* > "%USERPROFILE%\Desktop\eicar_file.txt"
start notepad "%USERPROFILE%\Desktop\eicar_file.txt"
exit
"@

# Save the batch file
Set-Content -Path $timerScriptPath -Value $scriptContent

# Run the timer in a new CMD window
Start-Process cmd.exe -ArgumentList "/c `"$timerScriptPath`""
