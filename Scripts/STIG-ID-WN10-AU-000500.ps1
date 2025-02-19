<#
.SYNOPSIS
    Configures the Application Event Log size to 32768 KB or greater.

.DESCRIPTION
    This script ensures that the Application Event Log size is set to at least 32,768 KB.
    It modifies the system registry and applies the setting to comply with STIG guidelines.

.NOTES
    Author         : Alejandro Perez Hernandez
    LinkedIn       : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub         : github.com/4le26x
    Date Created   : 2025-02-17
    Last Modified  : 2025-02-17
    Version        : 1.0
    STIG-ID        : WN10-AU-000500
    CVEs           : N/A
    Plugin IDs     : N/A

.TESTED ON
    Date(s) Tested  : 2025-02-18
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Run this script as Administrator:
    PS C:\> .\WN10-AU-000500.ps1
#>

# Ensure the script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Define the log size limit (32,768 KB or greater)
$LogSizeKB = 32768
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
$RegistryKey = "MaxSize"

# Check if the registry path exists, create if missing
if (-Not (Test-Path $RegistryPath)) {
    Write-Host "Registry path not found. Creating it..." -ForegroundColor Yellow
    New-Item -Path $RegistryPath -Force | Out-Null
}

# Set the registry value for maximum log size
Try {
    Set-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $LogSizeKB -Type DWord
    Write-Host "Successfully set Application Event Log size to $LogSizeKB KB." -ForegroundColor Green
} Catch {
    Write-Host "Error: Failed to modify the registry value. Check permissions." -ForegroundColor Red
}

# Verify the setting
$Verify = Get-ItemProperty -Path $RegistryPath -Name $RegistryKey | Select-Object -ExpandProperty $RegistryKey
if ($Verify -ge $LogSizeKB) {
    Write-Host "Verification: Application Event Log size is set to $Verify KB." -ForegroundColor Green
} else {
    Write-Host "Verification: The setting was not applied correctly. Please check manually." -ForegroundColor Red
}

# Force Group Policy update to apply changes
gpupdate /force

Write-Host "Configuration for Application Event Log size completed successfully." -ForegroundColor Cyan
