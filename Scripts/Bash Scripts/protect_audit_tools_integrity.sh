#!/usr/bin/env bash
# =============================================================================
# Script Name  : protect_audit_tools_integrity.sh
# Description  : Sets up AIDE to monitor and protect the integrity of audit tools by
#                configuring cryptographic (SHA512) checks on audit-related binaries.
# Author       : Alejandro Perez Hernandez 
# LinkedIn     :https://www.linkedin.com/in/alejandro-perez-hernandez-28158a120/
# GitHub       : https://github.com/4le26x
# Date Created : 2025-02-21
# Last Modified: 2025-02-21
# Version      : 1.0
# CVEs         : N/A
# STIG-ID      : LINUX-AUDIT-000132
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
#   sudo ./protect_audit_tools_integrity.sh
# =============================================================================
# REQUIREMENTS:
# - Must be executed with root privileges.
# - AIDE must be installed.
# - System must support cryptographic integrity checks.
# =============================================================================


# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root. Use sudo." >&2
    exit 1
fi

# Check if AIDE is installed, install if necessary
if ! command -v aide &> /dev/null; then
    echo "AIDE is not installed. Installing now..."
    apt-get update && apt-get install -y aide aide-common
fi

# Define AIDE configuration file
AIDE_CONF="/etc/aide/aide.conf"

# Define the audit tool integrity rules
AUDIT_RULES="
/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512
"

# Check if the rules already exist in the AIDE configuration
if grep -q "/sbin/auditctl" "$AIDE_CONF"; then
    echo "Audit tool integrity rules already exist in $AIDE_CONF. Skipping update."
else
    echo "Updating AIDE configuration to monitor audit tool integrity..."
    echo "$AUDIT_RULES" >> "$AIDE_CONF"
    echo "AIDE configuration updated."
fi

# Ensure the aide.conf file has the correct permissions
chmod 600 "$AIDE_CONF"
chown root:root "$AIDE_CONF"

# Initialize AIDE database (first-time setup if necessary)
if [ ! -f "/var/lib/aide/aide.db.gz" ]; then
    echo "Initializing AIDE database..."
    aideinit
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
fi

# Update AIDE database
echo "Updating AIDE database..."
aide --update
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Verify the rules were applied
echo "Verifying AIDE configuration..."
aide --check

echo "Audit tool integrity protection setup completed."