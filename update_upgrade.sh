#!/bin/bash

# Ansible-compatible update & upgrade script (no reboot)
# Safe to run from Semaphore

echo "=== Starting system update ==="

# Update package list
apt update

# Upgrade packages
apt upgrade -y

# Clean up unused packages
apt autoremove -y
apt autoclean -y

echo "=== Update & upgrade completed successfully ==="
