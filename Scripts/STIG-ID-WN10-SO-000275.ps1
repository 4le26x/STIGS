 <#
.SYNOPSIS
Displays a legal notice before login to enforce security policies and warnings.
.NOTES
    Author          : Alejandro Perez Hernandez 
    LinkedIn        : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub          : github.com/4le26x
    Date Created    : 2025-02-14
    Last Modified   : 2025-02-16
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000275

.TESTED ON
    Date(s) Tested  : 2025-02-14
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Execute this script in an elevated PowerShell session.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-SO-000275.ps1 
#>

# Ensure the script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Define registry path
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

# Set Legal Notice Caption
Try {
    Set-ItemProperty -Path $regPath -Name "LegalNoticeCaption" -Value "Unauthorized Access Prohibited"
    Write-Host "Successfully set Legal Notice Caption." -ForegroundColor Green
} Catch {
    Write-Host "Error: Failed to set Legal Notice Caption." -ForegroundColor Red
}

# Set Legal Notice Text
Try {
    Set-ItemProperty -Path $regPath -Name "LegalNoticeText" -Value "Access to this system is restricted to authorized users only."
    Write-Host "Successfully set Legal Notice Text." -ForegroundColor Green
} Catch {
    Write-Host "Error: Failed to set Legal Notice Text." -ForegroundColor Red
}

# Force Group Policy update
Write-Host "Applying Group Policy settings..." -ForegroundColor Yellow
gpupdate /force