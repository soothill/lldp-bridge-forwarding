#!/bin/bash
#
# LLDP Bridge Forwarding - Installation Script
# Author: Darren Soothill (soothill.io)
#

set -euo pipefail

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

echo "===== LLDP Bridge Forwarding Installation ====="
echo ""

# Copy the main script
echo "Installing main script..."
cp enable-lldp-forwarding.sh /usr/local/bin/
chmod +x /usr/local/bin/enable-lldp-forwarding.sh
echo "✓ Script installed to /usr/local/bin/enable-lldp-forwarding.sh"

# Copy the systemd service
echo "Installing systemd service..."
cp lldp-bridge-forwarding.service /etc/systemd/system/
chmod 644 /etc/systemd/system/lldp-bridge-forwarding.service
echo "✓ Service file installed to /etc/systemd/system/lldp-bridge-forwarding.service"

# Reload systemd
echo "Reloading systemd daemon..."
systemctl daemon-reload
echo "✓ Systemd daemon reloaded"

# Enable the service
echo "Enabling service to start on boot..."
systemctl enable lldp-bridge-forwarding.service
echo "✓ Service enabled"

# Run the service now
echo "Starting service..."
systemctl start lldp-bridge-forwarding.service
echo "✓ Service started"

echo ""
echo "===== Installation Complete ====="
echo ""
echo "Service status:"
systemctl status lldp-bridge-forwarding.service --no-pager || true
echo ""
echo "Log file location: /var/log/lldp-bridge-forward.log"
echo ""
echo "Useful commands:"
echo "  - Check status:  systemctl status lldp-bridge-forwarding"
echo "  - View logs:     journalctl -u lldp-bridge-forwarding"
echo "  - Restart:       systemctl restart lldp-bridge-forwarding"
echo "  - Disable:       systemctl disable lldp-bridge-forwarding"
echo ""
echo "To verify LLDP forwarding is enabled on a bridge:"
echo "  cat /sys/class/net/<bridge_name>/bridge/group_fwd_mask"
echo "  (Should show 0x4000 or higher)"
echo ""
