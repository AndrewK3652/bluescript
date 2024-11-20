#!/bin/bash

# Ensure script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Function to log operations
log_operation() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> /var/log/apt_restore.log
}

# Restore apt sources to original configuration
restore_apt_sources() {
    echo "Restoring apt sources to original configuration..."
    
    # Attempt to restore from backup (if exists)
    if [ -f "/etc/apt/sources.list.backup" ]; then
        cp /etc/apt/sources.list.backup /etc/apt/sources.list
        log_operation "Restored apt sources from backup"
    else
        # If no backup exists, create a default sources list
        cat > /etc/apt/sources.list << EOL
deb http://deb.debian.org/debian/ stable main contrib non-free
deb-src http://deb.debian.org/debian/ stable main contrib non-free

deb http://deb.debian.org/debian/ stable-updates main contrib non-free
deb-src http://deb.debian.org/debian/ stable-updates main contrib non-free

deb http://security.debian.org/debian-security stable-security main contrib non-free
deb-src http://security.debian.org/debian-security stable-security main contrib non-free
EOL
        log_operation "Created default apt sources list"
    fi

    # Update apt package lists
    apt update
    
    log_operation "Restored and updated apt sources"
}

# Main execution
main() {
    echo "Starting apt sources restoration..."
    
    # Create a backup of current sources before modification (if not exists)
    if [ ! -f "/etc/apt/sources.list.backup" ]; then
        cp /etc/apt/sources.list /etc/apt/sources.list.backup
        log_operation "Created backup of current sources list"
    fi
    
    restore_apt_sources
    
    echo "Apt sources restoration completed."
    log_operation "Apt sources restoration script completed successfully"
}

# Run the main function
main
