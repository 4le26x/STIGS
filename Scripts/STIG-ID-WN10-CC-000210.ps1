<#
.SYNOPSIS
    Ensures Windows Defender SmartScreen is enabled with strict protection.

.NOTES
    Author          : Alejandro Perez Hernandez 
    LinkedIn        : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub          : github.com/4le26x
    Date Created    : 2025-02-17
    Last Modified   : 2025-02-17
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000210

.TESTED ON
    Date(s) Tested  : 2025-02-18
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Run this script in an elevated PowerShell session.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000210.ps1 
#>


# Ensure the script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Error: This script must be run as Administrator. Please restart PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Define registry paths and values
$regPath1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$regName1 = "EnableSmartScreen"
$regValue1 = 1  # 1 = Enabled

$regPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$regName2 = "ShellSmartScreenLevel"
$regValue2 = "Block"  # "Warn" allows bypass, "Block" prevents bypass

# Ensure registry path exists
if (-Not (Test-Path $regPath1)) {
    Write-Host "Registry path not found. Creating it..." -ForegroundColor Yellow
    New-Item -Path $regPath1 -Force | Out-Null
}

# Apply SmartScreen settings
Try {
    Set-ItemProperty -Path $regPath1 -Name $regName1 -Value $regValue1 -Type DWord
    Set-ItemProperty -Path $regPath2 -Name $regName2 -Value $regValue2 -Type String
    Write-Host "Successfully enabled Windows Defender SmartScreen with 'Warn and prevent bypass'." -ForegroundColor Green
} Catch {
    Write-Host "Error: Failed to modify the registry values. Check permissions." -ForegroundColor Red
}

# Verify the settings
$verify1 = Get-ItemProperty -Path $regPath1 -Name $regName1 | Select-Object -ExpandProperty $regName1
$verify2 = Get-ItemProperty -Path $regPath2 -Name $regName2 | Select-Object -ExpandProperty $regName2

if ($verify1 -eq $regValue1 -and $verify2 -eq $regValue2) {
    Write-Host "Verification: Windows Defender SmartScreen is successfully enabled with protection." -ForegroundColor Green
} else {
    Write-Host "Verification: The setting was not applied correctly. Please check manually." -ForegroundColor Red
}

# Force Group Policy update
Write-Host "Applying Group Policy settings..." -ForegroundColor Yellow
gpupdate /force
