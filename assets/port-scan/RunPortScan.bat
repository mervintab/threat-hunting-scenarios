@echo off
REM Turn off command echoing to make the output cleaner.

set /p target="Enter target IP or range (default: 203.0.113.1-254): "
REM Prompt the user to enter a target IP address or range.
REM Store the user input in the variable 'target'.

if "%target%"=="" set target=203.0.113.1-254
REM If the user input is empty (just pressed Enter), set 'target' to the default IP range.

powershell.exe -ExecutionPolicy Bypass -File "C:\Path\To\PortScanSimulation.ps1" -TargetIPRange "%target%"
REM Run the PowerShell script 'PortScanSimulation.ps1', passing 'target' as the IP range.
REM Use -ExecutionPolicy Bypass to ensure the script runs without being blocked by policy.

pause
REM Keep the Command Prompt window open after script execution.
REM Wait for the user to press any key before closing the window.
