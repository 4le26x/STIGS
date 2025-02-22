#!/bin/bash
# =============================================================================
# Script Name  : ensure_audit_log_owner.sh
# Description  : Ensures that all audit log files are owned by root by verifying
#                and updating file ownership where necessary.
# Author       : Alejandro Perez Hernandez 
# LinkedIn     :https://www.linkedin.com/in/alejandro-perez-hernandez-28158a120/
# GitHub       : https://github.com/4le26x
# Date Created : 2025-02-21
# Last Modified: 2025-02-21
# Version      : 1.0
# CVEs         : N/A
# STIG-ID      : 6.3.4.2 (Ensure audit log files owner is configured)
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
#   sudo ./ensure_audit_log_owner.sh
# =============================================================================
# REQUIREMENTS:
# - Must be executed with root privileges.
# - 'auditd' package must be installed.
# - /etc/audit/auditd.conf must exist.
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


# Check if auditd.conf exists
AUDITD_CONF="/etc/audit/auditd.conf"

if [ ! -f "$AUDITD_CONF" ]; then
    echo "Error: $AUDITD_CONF not found. Audit daemon may not be installed." >&2
    exit 1
fi

# Extract the directory where audit logs are stored
AUDIT_LOG_DIR=$(dirname "$(awk -F "=" '/^\s*log_file/ {print $2}' "$AUDITD_CONF" | xargs)")

# Validate if the directory exists
if [ ! -d "$AUDIT_LOG_DIR" ]; then
    echo "Error: Audit log directory $AUDIT_LOG_DIR not found." >&2
    exit 1
fi

# Change ownership of all audit logs to root
echo "Ensuring audit log files in $AUDIT_LOG_DIR are owned by root..."
find "$AUDIT_LOG_DIR" -type f ! -user root -exec chown root {} +

# Verify ownership change
if find "$AUDIT_LOG_DIR" -type f ! -user root | grep -q .; then
    echo "Error: Some audit log files are still not owned by root." >&2
    exit 1
else
    echo "Success: All audit log files are now owned by root."
fi
