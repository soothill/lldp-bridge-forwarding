#!/bin/bash
#
# LLDP Bridge Forwarding - Status Check Script
# Author: Darren Soothill (soothill.io)
#

set -euo pipefail

LLDP_MASK=0x4000

echo "===== LLDP Bridge Forwarding Status ====="
echo ""

# Check if service exists and is enabled
if systemctl list-unit-files | grep -q "lldp-bridge-forwarding.service"; then
    echo "Service Status:"
    echo "  Installed: ✓"
    
    if systemctl is-enabled lldp-bridge-forwarding.service &>/dev/null; then
        echo "  Enabled: ✓"
    else
        echo "  Enabled: ✗"
    fi
    
    if systemctl is-active lldp-bridge-forwarding.service &>/dev/null; then
        echo "  Running: ✓"
    else
        echo "  Running: ✗"
    fi
else
    echo "Service Status: Not installed"
fi

echo ""
echo "Bridge Configurations:"
echo ""

# Find all bridges and check their status
found_bridge=false
for iface in /sys/class/net/*; do
    iface_name=$(basename "${iface}")
    if [[ -d "${iface}/bridge" ]]; then
        found_bridge=true
        mask=$(cat "${iface}/bridge/group_fwd_mask" 2>/dev/null || echo "0x0")
        
        # Check if LLDP bit is set
        if [[ $((mask & LLDP_MASK)) -eq $((LLDP_MASK)) ]]; then
            status="✓ ENABLED"
        else
            status="✗ DISABLED"
        fi
        
        printf "  %-15s mask: %-10s %s\n" "${iface_name}" "${mask}" "${status}"
    fi
done

if [[ "${found_bridge}" == false ]]; then
    echo "  No bridge interfaces found!"
fi

echo ""

# Check for log file
if [[ -f "/var/log/lldp-bridge-forward.log" ]]; then
    echo "Recent Log Entries:"
    echo "---"
    tail -n 5 /var/log/lldp-bridge-forward.log
    echo "---"
else
    echo "Log file not found: /var/log/lldp-bridge-forward.log"
fi

echo ""
echo "To view full service logs: journalctl -u lldp-bridge-forwarding"
echo "To manually restart: systemctl restart lldp-bridge-forwarding"
echo ""
