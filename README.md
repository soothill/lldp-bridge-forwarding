# LLDP Bridge Forwarding for Proxmox

## Overview

This solution enables LLDP (Link Layer Discovery Protocol) forwarding on Linux bridges used by Proxmox VE. By default, Linux bridges filter out LLDP frames, preventing network topology discovery across bridge interfaces. This script configures bridges to forward LLDP packets and maintains the configuration across reboots.

**Author:** Darren Soothill (soothill.io)

## Background

LLDP uses multicast MAC address `01:80:c2:00:00:0e` which is part of the reserved IEEE 802.1D range. Linux bridges filter these frames by default. To allow LLDP forwarding, we modify the bridge's `group_fwd_mask` parameter by setting bit 14 (0x4000).

## Files Included

- `enable-lldp-forwarding.sh` - Main script that configures bridges
- `lldp-bridge-forwarding.service` - Systemd service for persistence
- `install.sh` - Automated installation script
- `README.md` - This documentation

## Quick Installation

```bash
# Make install script executable
chmod +x install.sh

# Run as root
sudo ./install.sh
```

The installation script will:
1. Copy the main script to `/usr/local/bin/`
2. Install the systemd service
3. Enable the service to start on boot
4. Start the service immediately

## Manual Installation

If you prefer manual installation:

```bash
# Copy the main script
sudo cp enable-lldp-forwarding.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/enable-lldp-forwarding.sh

# Copy the systemd service
sudo cp lldp-bridge-forwarding.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/lldp-bridge-forwarding.service

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable lldp-bridge-forwarding.service
sudo systemctl start lldp-bridge-forwarding.service
```

## Verification

### Check Service Status

```bash
sudo systemctl status lldp-bridge-forwarding
```

### View Logs

```bash
# Systemd journal
sudo journalctl -u lldp-bridge-forwarding

# Script log file
sudo tail -f /var/log/lldp-bridge-forward.log
```

### Verify Bridge Configuration

```bash
# Check all bridges
for bridge in /sys/class/net/*/bridge; do
    iface=$(echo $bridge | cut -d'/' -f5)
    mask=$(cat $bridge/group_fwd_mask)
    echo "$iface: $mask"
done

# Check specific bridge (e.g., vmbr0)
cat /sys/class/net/vmbr0/bridge/group_fwd_mask
```

A value of `0x4000` or higher (with bit 14 set) indicates LLDP forwarding is enabled.

### Test LLDP Discovery

If you have `lldpd` or `lldpctl` installed:

```bash
# Install lldpd if needed
sudo apt-get install lldpd

# View LLDP neighbors
sudo lldpctl
```

## Compatibility

- **Proxmox VE:** 7.x, 8.x and newer
- **Linux Kernel:** Any recent kernel with bridge support
- **Bridge Types:** Works with all Linux bridge interfaces (vmbr0, vmbr1, etc.)

## How It Works

The script performs the following operations:

1. Scans `/sys/class/net/` for bridge interfaces
2. Reads the current `group_fwd_mask` for each bridge
3. Performs a bitwise OR with `0x4000` to enable LLDP forwarding
4. Writes the new mask back to the bridge
5. Verifies the configuration was applied successfully
6. Logs all operations to `/var/log/lldp-bridge-forward.log`

The systemd service ensures the script runs:
- At system boot (after network initialization)
- After Proxmox cluster services start
- Automatically restarts on failure

## Troubleshooting

### Service Fails to Start

Check the journal for errors:
```bash
sudo journalctl -u lldp-bridge-forwarding -n 50
```

### LLDP Still Not Working

1. Verify the mask is set correctly:
   ```bash
   cat /sys/class/net/vmbr0/bridge/group_fwd_mask
   ```

2. Check if LLDP daemon is running on connected devices

3. Verify physical connectivity and switch configuration

4. Use tcpdump to capture LLDP frames:
   ```bash
   sudo tcpdump -i vmbr0 -e ether proto 0x88cc
   ```

### Configuration Lost After Reboot

Verify the service is enabled:
```bash
sudo systemctl is-enabled lldp-bridge-forwarding
```

If not enabled:
```bash
sudo systemctl enable lldp-bridge-forwarding
```

## Advanced Configuration

### Applying to Specific Bridges Only

Edit `/usr/local/bin/enable-lldp-forwarding.sh` and modify the main function:

```bash
# Replace the automatic bridge detection with:
bridges=("vmbr0" "vmbr1")  # Specify your bridges here
```

### Different Forward Masks

To enable forwarding of other protocols, you can modify the `LLDP_MASK` variable. Common values:

- `0x4000` - LLDP (01:80:c2:00:00:0e)
- `0x8000` - Cisco protocols
- `0xC000` - Both LLDP and Cisco

### Integration with Proxmox Network Config

For Proxmox-native integration, you can add the following to `/etc/network/interfaces`:

```
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.1/24
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0
    post-up echo 0x4000 > /sys/class/net/vmbr0/bridge/group_fwd_mask
```

However, using the systemd service is recommended as it handles all bridges automatically.

## Uninstallation

To remove the LLDP forwarding configuration:

```bash
# Stop and disable the service
sudo systemctl stop lldp-bridge-forwarding
sudo systemctl disable lldp-bridge-forwarding

# Remove files
sudo rm /usr/local/bin/enable-lldp-forwarding.sh
sudo rm /etc/systemd/system/lldp-bridge-forwarding.service
sudo rm /var/log/lldp-bridge-forward.log

# Reload systemd
sudo systemctl daemon-reload
```

Bridge masks will revert to default after reboot.

## Technical References

- [Linux Bridge Documentation](https://www.kernel.org/doc/Documentation/networking/bridge.txt)
- [IEEE 802.1AB LLDP Standard](https://standards.ieee.org/standard/802_1AB-2016.html)
- [Proxmox VE Network Configuration](https://pve.proxmox.com/wiki/Network_Configuration)

## License

Copyright (c) 2025 Darren Soothill

This script is provided as-is without warranty. Use at your own risk.

## Author

**Darren Soothill**  
Website: [soothill.io](https://soothill.io)

For issues or contributions, please refer to the documentation at soothill.io.
