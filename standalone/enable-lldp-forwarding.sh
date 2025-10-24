#!/bin/bash
#
# LLDP Bridge Forwarding Script for Proxmox
# Author: Darren Soothill (soothill.io)
# 
# This script enables LLDP forwarding on Linux bridges by modifying
# the group_fwd_mask parameter. LLDP uses multicast address 01:80:c2:00:00:0e
# which is normally filtered by bridges.
#

set -euo pipefail

# Logging setup
LOG_FILE="/var/log/lldp-bridge-forward.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log_message() {
    echo "[${TIMESTAMP}] $1" | tee -a "${LOG_FILE}"
}

# LLDP forwarding requires bit 14 (0x4000) to be set in group_fwd_mask
# This allows forwarding of frames with destination MAC 01:80:c2:00:00:0e
LLDP_MASK=0x4000

# Function to enable LLDP forwarding on a single bridge
enable_lldp_on_bridge() {
    local bridge=$1
    local current_mask
    local new_mask
    
    if [[ ! -d "/sys/class/net/${bridge}/bridge" ]]; then
        log_message "WARNING: ${bridge} is not a bridge interface, skipping"
        return 1
    fi
    
    # Get current mask
    current_mask=$(cat "/sys/class/net/${bridge}/bridge/group_fwd_mask" 2>/dev/null || echo "0x0")
    
    # Calculate new mask (OR operation to preserve existing bits)
    new_mask=$(printf "0x%x" $((current_mask | LLDP_MASK)))
    
    # Apply the new mask
    echo "${new_mask}" > "/sys/class/net/${bridge}/bridge/group_fwd_mask"
    
    # Verify the change
    local verified_mask
    verified_mask=$(cat "/sys/class/net/${bridge}/bridge/group_fwd_mask")
    
    if [[ $((verified_mask & LLDP_MASK)) -eq $((LLDP_MASK)) ]]; then
        log_message "SUCCESS: LLDP forwarding enabled on ${bridge} (mask: ${verified_mask})"
        return 0
    else
        log_message "ERROR: Failed to enable LLDP forwarding on ${bridge}"
        return 1
    fi
}

# Main execution
main() {
    log_message "===== Starting LLDP Bridge Forwarding Configuration ====="
    
    # Find all bridge interfaces
    bridges=()
    for iface in /sys/class/net/*; do
        iface_name=$(basename "${iface}")
        if [[ -d "${iface}/bridge" ]]; then
            bridges+=("${iface_name}")
        fi
    done
    
    if [[ ${#bridges[@]} -eq 0 ]]; then
        log_message "WARNING: No bridge interfaces found"
        exit 1
    fi
    
    log_message "Found ${#bridges[@]} bridge interface(s): ${bridges[*]}"
    
    # Enable LLDP forwarding on each bridge
    success_count=0
    for bridge in "${bridges[@]}"; do
        if enable_lldp_on_bridge "${bridge}"; then
            ((success_count++))
        fi
    done
    
    log_message "===== Configuration Complete: ${success_count}/${#bridges[@]} bridges configured ====="
    
    if [[ ${success_count} -eq ${#bridges[@]} ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main
