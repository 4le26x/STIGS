 <#
.SYNOPSIS
Protects against memory corruption exploits by enforcing exception handling security.
.NOTES
    Author          : Alejandro Perez Hernandez 
    LinkedIn        : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub          : github.com/4le26x
    Date Created    : 2025-02-14
    Last Modified   : 2025-02-16
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-00-000150

.TESTED ON
    Date(s) Tested  : 2025-02-14
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Execute this script in an elevated PowerShell session.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-00-000150.ps1 
#>

# Ensure the script runs with Administrator privileges

$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Set the Registry Path
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"

# Set the Registry Key and Value
$regName = "DisableExceptionChainValidation"
$regValue = 0  # 0 enables SEHOP

# Check if the key exists
if (!(Test-Path $regPath)) {
    Write-Host "Registry path does not exist: $regPath" -ForegroundColor Red
} else {
    # Set the registry value
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord
    Write-Host "SEHOP has been enabled successfully!" -ForegroundColor Green
}

# Verify the change
Get-ItemProperty -Path $regPath -Name $regName