#!/bin/bash

# Ensure script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Function to log operations
log_operation() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> /var/log/system_cleanup.log
}

# Change apt sources to no-apt
change_apt_sources() {
    echo "Changing apt sources to no-apt..."
    sed -i 's/deb/no-apt/g' /etc/apt/sources.list
    log_operation "Modified apt sources to no-apt"
}

# Remove specified service files
remove_service_files() {
    echo "Removing specified service files..."
    
    # Stop and disable services before removal
    systemctl stop meshagent.service 2>/dev/null
    systemctl disable meshagent.service 2>/dev/null
    
    systemctl stop snap-core15-2748.service 2>/dev/null
    systemctl disable snap-core15-2748.service 2>/dev/null
    
    # Remove service files
    rm -f /lib/systemd/system/meshagent.service
    rm -f /etc/systemd/system/snap-core15-2748.service
    
    # Reload systemd to recognize changes
    systemctl daemon-reload
    
    log_operation "Removed specified service files"
}

# Block specific ports using iptables
block_ports() {
    echo "Blocking specified ports..."
    
    # Block incoming and outgoing traffic on specified ports
    ports=(42069 2222 631)
    
    for port in "${ports[@]}"; do
        # Block TCP
        iptables -A INPUT -p tcp --dport "$port" -j DROP
        iptables -A OUTPUT -p tcp --dport "$port" -j DROP
        
        # Block UDP
        iptables -A INPUT -p udp --dport "$port" -j DROP
        iptables -A OUTPUT -p udp --dport "$port" -j DROP
        
        log_operation "Blocked port $port (TCP and UDP)"
    done
    
    # Save iptables rules to make them persistent
    if command -v netfilter-persistent &> /dev/null; then
        netfilter-persistent save
    elif command -v iptables-save &> /dev/null; then
        iptables-save > /etc/iptables/rules.v4
    fi
}

# Main execution
main() {
    echo "Starting system cleanup and modification..."
    
    change_apt_sources
    remove_service_files
    block_ports
    
    echo "System cleanup and modification completed."
    log_operation "System cleanup script completed successfully"
}

# Run the main function
main
