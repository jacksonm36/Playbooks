#!/bin/bash

# Ansible-compatible update & upgrade script (no reboot)
# Safe to run from Semaphore

set -e

echo "=== Starting system update ==="

# Update package list
apt update -y

# Upgrade packages
apt upgrade -y

# Clean up unused packages
apt autoremove -y
apt autoclean -y

echo "=== Update & upgrade completed successfully ==="
