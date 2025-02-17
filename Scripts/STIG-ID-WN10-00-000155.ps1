 <#
.SYNOPSIS
    Removes outdated PowerShell 2.0 to prevent exploitation by attackers using legacy script execution.

.NOTES
    Author          : Alejandro Perez Hernandez 
    LinkedIn        : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub          : github.com/4le26x
    Date Created    : 2025-02-14
    Last Modified   : 2025-02-16
    Version         : 1.1
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-00-000155

.TESTED ON
    Date(s) Tested  : 2025-02-14
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Execute this script in an elevated PowerShell session.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-00-000155.ps1 
#>



# Ensure the script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Check if PowerShell 2.0 is enabled
$feature = Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
if ($feature.State -eq "Enabled") {
    Write-Host "PowerShell 2.0 is enabled. Disabling now..." -ForegroundColor Yellow
    
    # Disable PowerShell 2.0
    Try {
        Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart
        Write-Host "Successfully disabled PowerShell 2.0." -ForegroundColor Green
    } Catch {
        Write-Host "Error: Failed to disable PowerShell 2.0. Check permissions." -ForegroundColor Red
    }
} else {
    Write-Host "PowerShell 2.0 is already disabled." -ForegroundColor Green
}

# Verify if PowerShell 2.0 is disabled
$verify = Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
if ($verify.State -eq "Disabled") {
    Write-Host "Verification: PowerShell 2.0 is successfully disabled." -ForegroundColor Green
} else {
    Write-Host "Verification: The setting was not applied correctly. Please check manually." -ForegroundColor Red
}