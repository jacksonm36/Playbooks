#!/bin/bash

# Ansible-compatible update & upgrade script (no reboot)
# Safe to run from Semaphore

echo "=== Starting system update ==="

# Update package list
if ! apt-get update; then
    echo "❌ apt-get update failed"
    exit 1
fi

# Upgrade packages
if ! apt-get upgrade -y; then
    echo "❌ apt-get upgrade failed"
    exit 1
fi

# Clean up unused packages
apt-get autoremove -y
apt-get autoclean -y

echo "✅ Update & upgrade completed successfully"
