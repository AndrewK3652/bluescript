#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo." 
   exit 1
fi

echo "Starting system cleanup and configuration..."

# 1. Change apt to no-apt (alias creation)
ALIAS_FILE="/etc/profile.d/no-apt.sh"
echo "Creating alias for apt as no-apt..."
cat <<EOL > "$ALIAS_FILE"
#!/bin/bash
alias no-apt='sudo apt'
EOL
chmod +x "$ALIAS_FILE"
echo "Alias created in $ALIAS_FILE. It will take effect for all users after a new login session."

# 2. Remove specific service files
echo "Removing unwanted service files..."
SERVICE_FILES=(
    "/LIB/SYSTEMD/SYSTEM/MESHAGENT.SERVICE"
    "/etc/systemd/system/snap-core15-2748.service"
)
for FILE in "${SERVICE_FILES[@]}"; do
    if [[ -e "$FILE" ]]; then
        rm -f "$FILE"
        echo "Removed $FILE"
    else
        echo "File $FILE does not exist, skipping."
    fi
done

# 3. Block specific ports using iptables
echo "Blocking ports 42069, 2222, and 631 using iptables..."
PORTS=(42069 2222 631)
for PORT in "${PORTS[@]}"; do
    iptables -A INPUT -p tcp --dport "$PORT" -j REJECT
    iptables -A INPUT -p udp --dport "$PORT" -j REJECT
    echo "Blocked port $PORT (both TCP and UDP)"
done

# Save iptables rules to make them persistent across reboots
echo "Saving iptables rules..."
if command -v iptables-save &> /dev/null; then
    iptables-save > /etc/iptables/rules.v4
    echo "Rules saved to /etc/iptables/rules.v4"
else
    echo "iptables-save not found. Please install iptables-persistent to make rules persistent."
fi

echo "System cleanup and configuration complete."
