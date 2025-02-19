<#
.SYNOPSIS
    Configures User Account Control (UAC) to prompt administrators for consent on the secure desktop.

.NOTES
    Author          : Alejandro Perez Hernandez 
    LinkedIn        : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub          : github.com/4le26x
    Date Created    : 2025-02-17
    Last Modified   : 2025-02-17
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000250

.TESTED ON
    Date(s) Tested  : 2025-02-18
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Run this script in an elevated PowerShell session.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-SO-000250.ps1
#>


# Ensure script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Define the registry path and key
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$RegistryKey = "ConsentPromptBehaviorAdmin"
$ExpectedValue = 2  # 2 = Prompt for consent on the secure desktop

# Check if the registry path exists; if not, create it
if (-Not (Test-Path $RegistryPath)) {
    Write-Host "Registry path not found. Creating it..." -ForegroundColor Yellow
    New-Item -Path $RegistryPath -Force | Out-Null
}

# Set the registry value
Try {
    Set-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $ExpectedValue -Type DWord
    Write-Host "Successfully configured UAC to prompt for consent on the secure desktop." -ForegroundColor Green
} Catch {
    Write-Host "Error: Failed to modify the registry value. Check permissions." -ForegroundColor Red
}

# Verify the setting
$Verify = Get-ItemProperty -Path $RegistryPath -Name $RegistryKey -ErrorAction SilentlyContinue
if ($Verify -and $Verify.ConsentPromptBehaviorAdmin -eq $ExpectedValue) {
    Write-Host "Verification: UAC is correctly set to 'Prompt for consent on the secure desktop'." -ForegroundColor Green
} else {
    Write-Host "Verification: The setting was not applied correctly. Please check manually." -ForegroundColor Red
}

# Force Group Policy update
gpupdate /force

Write-Host "UAC configuration has been successfully applied." -ForegroundColor Cyan

