@echo off
set /p target="Enter target IP or range (default: 203.0.113.1-254): "
if "%target%"=="" set target=203.0.113.1-254
powershell.exe -ExecutionPolicy Bypass -File "C:\Path\To\PortScanSimulation.ps1" -TargetIPRange "%target%"
pause
