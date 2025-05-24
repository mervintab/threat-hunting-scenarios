<#
.SYNOPSIS
    Simulate a port scan on a user-specified IP address or range using Nmap with Execution Policy Bypass.
.DESCRIPTION
    This script accepts a target IP/range as input, validates Nmap presence, and runs the scan with logging.
#>

param (
    [string]$TargetIPRange = "203.0.113.1-254"  # Default range if none specified
)

# Bypass execution policy for the current session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Define logging location
$logFile = "$env:TEMP\\nmap_scan_log.txt"

# Validate Nmap installation
if (-not (Get-Command nmap -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Nmap is not installed or not in PATH. Exiting."
    Add-Content -Path $logFile -Value "$(Get-Date) - Error: Nmap not found. Exiting."
    exit 1
}

# Define scan parameters
$targetPorts = "22,3389,445,80,443"
$scanType = "-sS -f"  # SYN scan with fragmentation
$additionalOptions = "-T4 --open --randomize-hosts"
$outputFile = "$env:TEMP\\nmap_scan_results.txt"

# Construct and run Nmap command
$nmapCommand = "nmap $scanType $additionalOptions -p $targetPorts $TargetIPRange -oN `"$outputFile`""
Write-Host "Starting Nmap scan on target: $TargetIPRange"
Add-Content -Path $logFile -Value "$(Get-Date) - Starting Nmap scan on target: $TargetIPRange."

try {
    Start-Process -FilePath "nmap" -ArgumentList "$scanType $additionalOptions -p $targetPorts $TargetIPRange -oN `"$outputFile`"" -NoNewWindow -Wait
    if (Test-Path $outputFile) {
        Write-Host "`nNmap scan completed. Results saved to $outputFile`n"
        Add-Content -Path $logFile -Value "$(Get-Date) - Nmap scan completed. Results saved to $outputFile."
        Get-Content $outputFile
    } else {
        Write-Host "Nmap scan failed. Output file not found."
        Add-Content -Path $logFile -Value "$(Get-Date) - Nmap scan failed. Output file missing."
    }
} catch {
    Write-Host "An error occurred during the Nmap scan: $_"
    Add-Content -Path $logFile -Value "$(Get-Date) - Error: $_"
}

Write-Host "Port scan simulation completed."
Add-Content -Path $logFile -Value "$(Get-Date) - Port scan simulation completed."
