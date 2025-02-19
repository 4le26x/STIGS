<#
.SYNOPSIS
    Disables indexing of encrypted files for Windows Search.

.DESCRIPTION
    This script configures Windows Search settings to prevent encrypted files from being indexed.
    It sets the policy value for 'Allow indexing of encrypted files' to Disabled.

.NOTES
    Author         : Alejandro Perez Hernandez
    LinkedIn       : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub         : github.com/4le26x
    Date Created   : 2025-02-17
    Last Modified  : 2025-02-17
    Version        : 1.0
    STIG-ID        : WN10-CC-000305
    CVEs           : N/A
    Plugin IDs     : N/A

.TESTED ON
    Date(s) Tested  : 2025-02-17
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x
.USAGE
    Run this script as Administrator:
    PS C:\> .\WN10-CC-000305.ps1
#>

# Ensure the script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Define the registry path and key
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$regName = "AllowIndexingEncryptedStoresOrItems"
$regValue = 0  # 0 = Disabled

# Check if the registry path exists, create if missing
if (-Not (Test-Path $regPath)) {
    Write-Host "Registry path not found. Creating it..." -ForegroundColor Yellow
    New-Item -Path $regPath -Force | Out-Null
}

# Apply the registry setting
Try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord
    Write-Host "Successfully disabled indexing of encrypted files." -ForegroundColor Green
} Catch {
    Write-Host "Error: Failed to modify the registry value. Check permissions." -ForegroundColor Red
}

# Force Group Policy update
gpupdate /force

# Verify the setting
$verify = Get-ItemProperty -Path $regPath -Name $regName | Select-Object -ExpandProperty $regName
if ($verify -eq 0) {
    Write-Host "Verification: Indexing of encrypted files is successfully disabled." -ForegroundColor Green
} else {
    Write-Host "Verification: The setting was not applied correctly. Please check manually." -ForegroundColor Red
}