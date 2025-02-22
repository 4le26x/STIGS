#!/bin/bash
# =============================================================================
# Script Name  : collect_mac_policy_mod_events.sh
# Description  : Configures audit rules to monitor events that modify the system's
#                Mandatory Access Controls (MAC), specifically tracking changes
#                in AppArmor policies.
# Author       : Alejandro Perez Hernandez 
# LinkedIn     :https://www.linkedin.com/in/alejandro-perez-hernandez-28158a120/
# GitHub       : https://github.com/4le26x
# Date Created : 2025-02-21
# Last Modified: 2025-02-21
# Version      : 1.0
# CVEs         : N/A
# STIG-ID      : LINUX-AUDIT-000128
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
#   sudo ./collect_mac_policy_mod_events.sh
# =============================================================================
# REQUIREMENTS:
# - Must be executed with root privileges.
# - 'auditd' package must be installed.
# - Audit rules directory must exist.
# =============================================================================


# Ensure the script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root. Use sudo." >&2
    exit 1
fi

# Define the audit rules directory
AUDIT_RULES_DIR="/etc/audit/rules.d"
AUDIT_RULE_FILE="$AUDIT_RULES_DIR/50-MAC-policy.rules"

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


# Ensure the audit rules directory exists
if [ ! -d "$AUDIT_RULES_DIR" ]; then
    echo "Creating audit rules directory: $AUDIT_RULES_DIR"
    mkdir -p "$AUDIT_RULES_DIR"
fi

# Define the audit rules for monitoring MAC policy modifications
AUDIT_RULES="
-w /etc/apparmor/ -p wa -k MAC-policy
-w /etc/apparmor.d/ -p wa -k MAC-policy
"

# Write the rules to the file
echo "Adding audit rules for MAC policy modifications..."
echo "$AUDIT_RULES" > "$AUDIT_RULE_FILE"

# Set appropriate permissions
chmod 640 "$AUDIT_RULE_FILE"

# Merge and load the new audit rules
echo "Loading audit rules..."
augenrules --load

# Check if reboot is required
if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then
    echo "Reboot required to load rules."
else
    echo "Audit rules successfully applied."
fi