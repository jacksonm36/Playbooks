#!/bin/bash

# System Update and Upgrade Script
# Ansible-compatible with proper exit codes and messaging

set -e  # Exit immediately if a command exits with a non-zero status

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log "Running as root user"
    else
        error "This script requires root privileges. Please run with sudo."
        exit 1
    fi
}

# Function to detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        error "Unsupported package manager"
        exit 1
    fi
}

# Function to update system based on package manager
update_system() {
    local pm=$1
    
    log "Detected package manager: $pm"
    log "Starting system update process..."
    
    case $pm in
        "apt")
            log "Updating package lists..."
            apt-get update
            
            log "Upgrading packages..."
            apt-get upgrade -y
            
            log "Performing distribution upgrade..."
            apt-get dist-upgrade -y
            
            log "Removing unnecessary packages..."
            apt-get autoremove -y
            
            log "Cleaning up package cache..."
            apt-get autoclean -y
            ;;
            
        "yum")
            log "Updating system..."
            yum update -y
            ;;
            
        "dnf")
            log "Updating system..."
            dnf update -y
            ;;
            
        "zypper")
            log "Refreshing repositories..."
            zypper refresh
            
            log "Updating system..."
            zypper update -y
            ;;
            
        "pacman")
            log "Updating system..."
            pacman -Syu --noconfirm
            ;;
    esac
}

# Main execution
main() {
    log "Starting system update script"
    
    # Check if running as root
    check_root
    
    # Detect package manager
    package_manager=$(detect_package_manager)
    
    # Update system
    if update_system "$package_manager"; then
        log "System update completed successfully!"
        echo "=========================================="
        echo "SUCCESS: System has been updated and upgraded"
        echo "Package manager: $package_manager"
        echo "Timestamp: $(date)"
        echo "=========================================="
        exit 0
    else
        error "System update failed!"
        exit 1
    fi
}

# Handle script interruption
trap 'error "Script interrupted by user"; exit 130' INT TERM

# Run main function
main "$@"