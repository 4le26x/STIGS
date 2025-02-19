<#
.SYNOPSIS
    Configures IPv6 Source Routing to the highest protection level.

.DESCRIPTION
    This script modifies the Windows registry to enforce the highest level of IPv6 source routing protection.
    It sets the DisableIPSourceRouting value to `2`, ensuring that source routing is completely disabled.

.NOTES
    Author         : Alejandro Perez Hernandez
    LinkedIn       : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub         : github.com/4le26x
    Date Created   : 2025-02-17
    Last Modified  : 2025-02-17
    Version        : 1.0
    STIG-ID        : WN10-CC-000020
    CVEs           : N/A
    Plugin IDs     : N/A

.TESTED ON
    Date(s) Tested  : 2025-02-18
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Run this script as Administrator:
    PS C:\> .\WN10-CC-000020.ps1

#>

# Ensure the script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Define the registry path and key
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
$regName = "DisableIPSourceRouting"
$regValue = 2  # 2 = Highest protection, completely disabled

# Check if the registry path exists, create if missing
if (-Not (Test-Path $regPath)) {
    Write-Host "Registry path not found. Creating it..." -ForegroundColor Yellow
    New-Item -Path $regPath -Force | Out-Null
}

# Apply the registry setting
Try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord
    Write-Host "Successfully set 'DisableIPSourceRouting' to 2 (Highest protection, disabled)." -ForegroundColor Green
} Catch {
    Write-Host "Error: Failed to modify the registry value. Check permissions." -ForegroundColor Red
}

# Force Group Policy update
gpupdate /force

# Verify the setting
$verify = Get-ItemProperty -Path $regPath -Name $regName | Select-Object -ExpandProperty $regName
if ($verify -eq 2) {
    Write-Host "Verification: 'DisableIPSourceRouting' is successfully set to 2 (Highest Protection)." -ForegroundColor Green
} else {
    Write-Host "Verification: The setting was not applied correctly. Please check manually." -ForegroundColor Red
}