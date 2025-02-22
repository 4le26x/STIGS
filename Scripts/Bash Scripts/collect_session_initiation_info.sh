#!/bin/bash
# =============================================================================
# Script Name  : collect_session_initiation_info.sh
# Description  : Configures audit rules to collect session initiation data by
#                monitoring files such as utmp, wtmp, and btmp.
# Author       : Alejandro Perez Hernandez 
# LinkedIn     :https://www.linkedin.com/in/alejandro-perez-hernandez-28158a120/
# GitHub       : https://github.com/4le26x
# Date Created : 2025-02-21
# Last Modified: 2025-02-21
# Version      : 1.0
# CVEs         : N/A
# STIG-ID      : 6.3.3.11 (Ensure session initiation information is collected)
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
#   sudo ./collect_session_initiation_info.sh
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

# Define audit rules directory and rule file
AUDIT_RULES_DIR="/etc/audit/rules.d"
AUDIT_RULE_FILE="$AUDIT_RULES_DIR/50-session.rules"

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

# Add audit rules for monitoring session initiation logs
echo "Adding audit rules for monitoring session initiation information..."
cat <<EOF > "$AUDIT_RULE_FILE"
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session
EOF

# Set appropriate permissions
chmod 640 "$AUDIT_RULE_FILE"

# Load the updated audit rules
echo "Loading audit rules..."
