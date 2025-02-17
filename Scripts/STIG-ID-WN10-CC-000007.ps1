
 <#
.SYNOPSIS
    Blocks unauthorized camera access to prevent privacy risks and potential espionage.

.NOTES
    Author          : Alejandro Perez Hernandez 
    LinkedIn        : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub          : github.com/4le26x
    Date Created    : 2025-02-14
    Last Modified   : 2025-02-16
    Version         : 1.1
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000007

.TESTED ON
    Date(s) Tested  : 2025-02-14
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Execute this script in an elevated PowerShell session.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000007.ps1 
#>



# Ensure the script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Define registry path and key
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam"
$regName = "Value"
$regValue = "Deny"

# Check if the registry path exists, create it if missing
if (-Not (Test-Path $regPath)) {
    Write-Host "Registry path not found. Creating it..." -ForegroundColor Yellow
    New-Item -Path $regPath -Force | Out-Null
}

# Set the registry value to deny webcam access
Try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type String
    Write-Host "Successfully disabled camera access (`Value` = 'Deny')." -ForegroundColor Green
} Catch {
    Write-Host "Error: Failed to modify the registry value. Check permissions." -ForegroundColor Red
}

# Force Group Policy update
Write-Host "Applying Group Policy settings..." -ForegroundColor Yellow
gpupdate /force
