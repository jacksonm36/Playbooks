#!/bin/bash

# Update & upgrade script (no reboot)
# Author: Jenő's automation assistant

LOGFILE="/var/log/update_upgrade.log"

echo "[$(date)] Starting system update..." | tee -a "$LOGFILE"

# Update package list
if apt update >> "$LOGFILE" 2>&1; then
    echo "[$(date)] Package list updated successfully." | tee -a "$LOGFILE"
else
    echo "[$(date)] ERROR: Failed to update package list." | tee -a "$LOGFILE"
    exit 1
fi

# Upgrade packages
if apt upgrade -y >> "$LOGFILE" 2>&1; then
    echo "[$(date)] Packages upgraded successfully." | tee -a "$LOGFILE"
else
    echo "[$(date)] ERROR: Failed to upgrade packages." | tee -a "$LOGFILE"
    exit 1
fi

# Autoremove and autoclean
apt autoremove -y >> "$LOGFILE" 2>&1
apt autoclean -y >> "$LOGFILE" 2>&1
echo "[$(date)] Cleanup completed." | tee -a "$LOGFILE"

echo "[$(date)] Update & upgrade process completed. No reboot triggered." | tee -a "$LOGFILE"