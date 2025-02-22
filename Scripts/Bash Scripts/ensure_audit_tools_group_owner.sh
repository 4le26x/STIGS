#!/bin/bash
# =============================================================================
# Script Name  : ensure_audit_tools_group_owner.sh
# Description  : Configures the group ownership of audit-related binaries to 'root'
#                to ensure proper permission settings for audit tools.
# Author       : Alejandro Perez Hernandez 
# LinkedIn     :https://www.linkedin.com/in/alejandro-perez-hernandez-28158a120/
# GitHub       : https://github.com/4le26x
# Date Created : 2025-02-21
# Last Modified: 2025-02-21
# Version      : 1.0
# CVEs         : N/A
# STIG-ID      : LINUX-AUDIT-000125
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
#   sudo ./ensure_audit_tools_group_owner.sh
# =============================================================================
# REQUIREMENTS:
# - Must be executed with root privileges.
# - 'auditd' package must be installed.
# - The specified audit binaries must exist on the system.
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

# Define audit-related binaries
AUDIT_BINARIES=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/augenrules"
)

# Loop through each binary and update group ownership
for BIN in "${AUDIT_BINARIES[@]}"; do
    if [ -f "$BIN" ]; then
        echo "Setting group ownership to root for: $BIN"
        chgrp root "$BIN"
    else
        echo "Warning: $BIN not found. Skipping..."
    fi
done

# Verify changes
echo "Verifying changes..."
for BIN in "${AUDIT_BINARIES[@]}"; do
    if [ -f "$BIN" ]; then
        ls -l "$BIN"
    fi
done

echo "Audit tool group ownership update completed."