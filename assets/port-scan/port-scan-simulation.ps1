<#
.SYNOPSIS
    Simulate a comprehensive port scan on a user-specified IP address or range using Nmap with Execution Policy Bypass.
.DESCRIPTION
    This script accepts a target IP/range as input, checks for Nmap, installs it if missing, and runs a comprehensive scan with logging.
#>

param (
    [string]$TargetIPRange = "203.0.113.1-254"  # Default range if none specified
)

# Bypass execution policy for the current session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Define logging location
$logFile = "$env:TEMP\\nmap_scan_log.txt"

# Function to install Nmap using Chocolatey
function Install-Nmap {
    Write-Host "Attempting to install Nmap using Chocolatey..."
    Add-Content -Path $logFile -Value "$(Get-Date) - Installing Nmap..."
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey is not installed. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host "Failed to install Chocolatey. Please install it manually."
            Add-Content -Path $logFile -Value "$(Get-Date) - Chocolatey installation failed."
            exit 1
        }
    }
    choco install nmap -y
}

# Validate Nmap installation, install if missing
if (-not (Get-Command nmap -ErrorAction SilentlyContinue)) {
    Write-Host "Nmap is not installed. Installing now..."
    Install-Nmap
    if (-not (Get-Command nmap -ErrorAction SilentlyContinue)) {
        Write-Host "Nmap installation failed. Exiting."
        Add-Content -Path $logFile -Value "$(Get-Date) - Nmap installation failed. Exiting."
        exit 1
    } else {
        Write-Host "Nmap installed successfully."
        Add-Content -Path $logFile -Value "$(Get-Date) - Nmap installed successfully."
    }
}

# Comprehensive scan parameters
$scanType = "-sS -A -p- -T4 -v --open --randomize-hosts"  # SYN scan, OS detection, version detection, scripts, traceroute, all ports
$outputFile = "$env:TEMP\\nmap_comprehensive_scan_results.txt"

# Construct and run Nmap command
$nmapCommand = "nmap $scanType $TargetIPRange -oN `"$outputFile`""
Write-Host "Starting comprehensive Nmap scan on target: $TargetIPRange"
Add-Content -Path $logFile -Value "$(Get-Date) - Starting comprehensive Nmap scan on target: $TargetIPRange."

try {
    Start-Process -FilePath "nmap" -ArgumentList "$scanType $TargetIPRange -oN `"$outputFile`"" -NoNewWindow -Wait
    if (Test-Path $outputFile) {
        Write-Host "`nNmap comprehensive scan completed. Results saved to $outputFile`n"
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

Write-Host "Comprehensive port scan simulation completed."
Add-Content -Path $logFile -Value "$(Get-Date) - Comprehensive port scan simulation completed."
