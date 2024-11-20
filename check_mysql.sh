#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo." 
   exit 1
fi

# Define the MySQL service name
SERVICE="mysql"

# Function to check and ensure MySQL is running
check_and_start_mysql() {
    # Check if MySQL is active
    if systemctl is-active --quiet "$SERVICE"; then
        echo "$(date): $SERVICE is running."
    else
        echo "$(date): $SERVICE is not running. Starting it..."
        systemctl start "$SERVICE"
        if systemctl is-active --quiet "$SERVICE"; then
            echo "$(date): Successfully started $SERVICE."
        else
            echo "$(date): Failed to start $SERVICE."
        fi
    fi

    # Ensure MySQL is enabled to start at boot
    if ! systemctl is-enabled --quiet "$SERVICE"; then
        echo "$(date): $SERVICE is not enabled. Enabling it..."
        systemctl enable "$SERVICE"
        if systemctl is-enabled --quiet "$SERVICE"; then
            echo "$(date): Successfully enabled $SERVICE."
        else
            echo "$(date): Failed to enable $SERVICE."
        fi
    fi
}

# Run the function
check_and_start_mysql
