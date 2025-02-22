#!/bin/bash
# =============================================================================
# Script Name  : enable_auditd_service.sh
# Description  : Unmasks, enables, and starts the auditd service to ensure that
#                auditing is active on the system.
# Author       : Alejandro Perez Hernandez 
# LinkedIn     :https://www.linkedin.com/in/alejandro-perez-hernandez-28158a120/
# GitHub       : https://github.com/4le26x
# Date Created : 2025-02-21
# Last Modified: 2025-02-21
# Version      : 1.0
# CVEs         : N/A
# STIG-ID      : LINUX-AUDIT-000126
# =============================================================================
# TESTED ON:
# - Date(s) Tested  : 2025-02-21
# - Tested By       : Alejandro Perez Hernandez 
# - Systems Tested  : Ubuntu 22.04.5 LTS, Jammy
# - Bash Version    : 5.1.16(1)-release
# =============================================================================
# USAGE:
# Run this script as root or with sudo privileges.
# Example:
#   sudo ./enable_auditd_service.sh
# =============================================================================
# REQUIREMENTS:
# - Must be executed with root privileges.
# - 'auditd' package must be installed.
# =============================================================================


# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root. Use sudo." >&2
    exit 1
fi


# Check if auditd is installed, install if missing
if ! command -v auditctl &> /dev/null; then
    echo "auditd is not installed. Installing now..."
    apt update && apt install -y auditd audispd-plugins
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install auditd." >&2
        exit 1
    fi
    echo "auditd installed successfully."
fi

echo "Unmasking auditd service..."
systemctl unmask auditd

echo "Enabling auditd to start on boot..."
systemctl enable auditd

echo "Starting auditd service..."
systemctl start auditd

# Verify auditd status
echo "Checking auditd service status..."
systemctl status auditd --no-pager

echo "AuditD setup completed successfully."