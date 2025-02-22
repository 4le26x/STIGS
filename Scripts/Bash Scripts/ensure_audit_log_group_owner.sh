#!/bin/bash
# =============================================================================
# Script Name  : ensure_audit_log_group_owner.sh
# Description  : Ensures that the audit log files’ group ownership is set to 'adm'
#                by updating file permissions and configuring auditd settings.
# Author       : Alejandro Perez Hernandez 
# LinkedIn     :https://www.linkedin.com/in/alejandro-perez-hernandez-28158a120/
# GitHub       : https://github.com/4le26x
# Date Created : 2025-02-21
# Last Modified: 2025-02-21
# Version      : 1.0
# CVEs         : N/A
# STIG-ID      : LINUX-AUDIT-000123
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
#   sudo ./ensure_audit_log_group_owner.sh
# =============================================================================
# REQUIREMENTS:
# - Must be executed with root privileges.
# - 'auditd' package must be installed.
# - System must support audit log configuration.
# =============================================================================


# Ensure the script is run as root
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

# Validate auditd installation
if ! systemctl is-active --quiet auditd; then
    echo "auditd is not running. Starting now..."
    systemctl enable --now auditd
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start auditd." >&2
        exit 1
    fi
    echo "auditd started successfully."
fi

# Ensure audit log files are group-owned by adm
LOG_DIR=$(dirname "$(awk -F"=" '/^\s*log_file/ {print $2}' /etc/audit/auditd.conf | xargs)")

if [ -d "$LOG_DIR" ]; then
    echo "Updating group ownership of audit logs..."
    find "$LOG_DIR" -type f \( ! -group adm -a ! -group root \) -exec chgrp adm {} +
    echo "Audit log files group ownership updated to adm."
else
    echo "Error: Audit log directory not found. Skipping ownership update." >&2
fi

# Set log_group = adm in auditd.conf
echo "Configuring auditd log group to 'adm'..."
sed -ri 's/^\s*#?\s*log_group\s*=\s*\S+.*/log_group = adm/' /etc/audit/auditd.conf

# Restart auditd to apply changes
echo "Restarting auditd service..."
systemctl restart auditd

# Verify auditd status
if systemctl is-active --quiet auditd; then
    echo "auditd is running and configuration is updated."
else
    echo "Error: auditd failed to restart. Check logs." >&2
    exit 1
fi

echo "Auditd configuration completed successfully."