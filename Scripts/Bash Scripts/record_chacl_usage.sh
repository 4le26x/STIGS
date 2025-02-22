#!/bin/bash
# =============================================================================
# Script Name  : record_chacl_usage.sh
# Description  : Configures an audit rule to record both successful and unsuccessful
#                attempts to execute the 'chacl' command.
# Author       : Alejandro Perez Hernandez 
# LinkedIn     :https://www.linkedin.com/in/alejandro-perez-hernandez-28158a120/
# GitHub       : https://github.com/4le26x
# Date Created : 2025-02-21
# Last Modified: 2025-02-21
# Version      : 1.0
# CVEs         : N/A
# STIG-ID      : 6.3.3.17 (Ensure successful and unsuccessful attempts to use the chacl command are recorded)
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
#   sudo ./record_chacl_usage.sh
# =============================================================================
# REQUIREMENTS:
# - Must be executed with root privileges.
# - 'auditd' package must be installed.
# - /etc/login.defs must define UID_MIN.
# =============================================================================


# Ensure the script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root. Use sudo." >&2
    exit 1
fi

# Define audit rules directory and rule file
AUDIT_RULES_DIR="/etc/audit/rules.d"
AUDIT_RULE_FILE="$AUDIT_RULES_DIR/50-perm_chng.rules"

# Ensure auditd is installed, install if missing
if ! command -v auditctl &> /dev/null; then
    echo "Audit daemon is not installed. Installing now..."
    apt-get update && apt-get install -y auditd audispd-plugins
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install auditd. Please check your package manager." >&2
        exit 1
    fi
    echo "Audit daemon installed successfully."
fi


# Ensure audit rules directory exists
if [ ! -d "$AUDIT_RULES_DIR" ]; then
    echo "Creating audit rules directory: $AUDIT_RULES_DIR"
    mkdir -p "$AUDIT_RULES_DIR"
fi

# Retrieve UID_MIN from /etc/login.defs
UID_MIN=$(awk '/^s*UID_MIN/{print $2}' /etc/login.defs)

# Validate if UID_MIN is set
if [ -z "$UID_MIN" ]; then
    echo "ERROR: UID_MIN variable is unset. Cannot proceed." >&2
    exit 1
fi

# Add audit rule for monitoring `chacl`
echo "Adding audit rule for monitoring chacl command..."
echo "-a always,exit -F path=/usr/bin/chacl -F perm=x -F auid>=$UID_MIN -F auid!=unset -k perm_chng" > "$AUDIT_RULE_FILE"

# Set appropriate permissions
chmod 640 "$AUDIT_RULE_FILE"

# Load the updated audit rules
echo "Loading audit rules..."
augenrules --load

# Check if reboot is required
if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then
    echo "Reboot required to load rules."
else
    echo "Audit rules successfully applied."
fi
