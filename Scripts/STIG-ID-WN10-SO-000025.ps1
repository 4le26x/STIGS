<#
.SYNOPSIS
    Renames the built-in Guest account for security compliance.

.DESCRIPTION
    This script modifies the local security policy to rename the built-in Guest account,
    preventing attackers from targeting the default 'Guest' username.

.NOTES
    Author         : Alejandro Perez Hernandez
    LinkedIn       : linkedin.com/in/alejandro-perez-hernandez-28158a120
    GitHub         : github.com/4le26x
    Date Created   : 2025-02-17
    Last Modified  : 2025-02-17
    Version        : 1.0
    STIG-ID        : WN10-SO-000025
    CVEs           : N/A
    Plugin IDs     : N/A

.TESTED ON
    Date(s) Tested  : 2025-02-18
    Tested By       : Alejandro Perez Hernandez
    Systems Tested  : Windows 10.0.19045 N/A Build 19045 
    PowerShell Ver. : PowerShell 5.x

.USAGE
    Run this script as Administrator:
    PS C:\> .\WN10-SO-000025.ps1
#>

# Ensure the script runs as Administrator
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Set the new name for the Guest account (modify as needed)
$NewGuestName = "LimitedUser"

# Get the current Guest account name
$GuestAccount = Get-WmiObject Win32_UserAccount -Filter "SID LIKE 'S-1-5-21-%-501'"

if ($GuestAccount) {
    if ($GuestAccount.Name -eq $NewGuestName) {
        Write-Host "The Guest account is already renamed to '$NewGuestName'. No changes needed." -ForegroundColor Green
    } else {
        # Rename the Guest account
        Try {
            Rename-LocalUser -Name $GuestAccount.Name -NewName $NewGuestName
            Write-Host "Successfully renamed Guest account to '$NewGuestName'." -ForegroundColor Green
        } Catch {
            Write-Host "Error: Failed to rename the Guest account. Check permissions." -ForegroundColor Red
        }
    }
} else {
    Write-Host "Guest account not found or already disabled." -ForegroundColor Yellow
}

# Verify the new account name
$Verify = Get-WmiObject Win32_UserAccount -Filter "SID LIKE 'S-1-5-21-%-501'"
if ($Verify.Name -eq $NewGuestName) {
    Write-Host "Verification: Guest account successfully renamed to '$NewGuestName'." -ForegroundColor Green
} else {
    Write-Host "Verification: The setting was not applied correctly. Please check manually." -ForegroundColor Red
}