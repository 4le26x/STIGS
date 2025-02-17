
 <#
.SYNOPSIS
    Prevents slide shows on the lock screen to reduce security risks from unauthorized content exposure.

.NOTES
    Author          : Alejandro Perez Hernandez 
    LinkedIn        : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub          : github.com/4le26x
    Date Created    : 2025-02-14
    Last Modified   : 2025-02-16
    Version         : 1.1
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000010 

.TESTED ON
    Date(s) Tested  : 2025-02-14
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Execute this script in an elevated PowerShell session.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000010.ps1 
#>

# Ensure the script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Define registry path and key
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$regName = "NoLockScreenSlideshow"
$regValue = 1

# Check if the registry path exists
if (-Not (Test-Path $regPath)) {
    Write-Host "Registry path not found. Creating it..." -ForegroundColor Yellow
    New-Item -Path $regPath -Force | Out-Null
}

# Set the registry value
Try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord
    Write-Host "Successfully set 'NoLockScreenSlideshow' to 1 (Disabled)." -ForegroundColor Green
} Catch {
    Write-Host "Error: Failed to modify the registry value. Check permissions." -ForegroundColor Red
}

# Force Group Policy update
gpupdate /force

# Verify the setting
$verify = Get-ItemProperty -Path $regPath -Name $regName | Select-Object -ExpandProperty $regName
if ($verify -eq 1) {
    Write-Host "Verification: 'NoLockScreenSlideshow' is successfully set to Disabled (1)." -ForegroundColor Green
} else {
    Write-Host "Verification: The setting was not applied correctly. Please check manually." -ForegroundColor Red
}