# LLDP Bridge Forwarding for Proxmox

Enable LLDP (Link Layer Discovery Protocol) forwarding on Proxmox VE bridge interfaces with persistent configuration. Choose between standalone scripts for single-host deployments or Ansible automation for multi-host infrastructure.

**Author:** Darren Soothill ([soothill.io](https://soothill.io))

## 📂 Repository Structure

This repository is organized into two main deployment methods:

### [`standalone/`](standalone/)
Traditional bash scripts for manual installation on individual Proxmox hosts.

**What's included:**
- `enable-lldp-forwarding.sh` - Core script that configures bridge forwarding
- `lldp-bridge-forwarding.service` - Systemd service for persistence
- `install.sh` - Automated installation script
- `check-lldp-status.sh` - Verification and status checking utility
- Complete standalone documentation

**Best for:**
- Single Proxmox host deployments
- Quick manual installations
- Learning and testing
- Environments without Ansible

**Quick start:**
```bash
cd standalone/
sudo ./install.sh
```

### [`ansible-deployment/`](ansible-deployment/)
Complete Ansible automation for deploying LLDP forwarding to multiple Proxmox hosts.

**What's included:**
- `deploy-lldp-forwarding.yml` - Main Ansible playbook
- `inventory.yml` - Host configuration template
- `Makefile` - Convenient deployment commands
- `quick-start.sh` - Interactive setup wizard
- `ansible.cfg` - Ansible configuration
- `requirements.yml` - Dependencies
- `group_vars/` and `host_vars/` - Flexible configuration
- Comprehensive Ansible documentation

**Best for:**
- Multiple Proxmox hosts (clusters)
- Infrastructure as Code (IaC)
- Automated deployments
- Production environments
- CI/CD integration

**Quick start:**
```bash
cd ansible-deployment/
./quick-start.sh
# or
make deploy
```

### Option 1: Standalone Installation

Perfect for single Proxmox hosts or quick manual deployments:

```bash
cd standalone/
sudo ./install.sh
```

See the [standalone README](standalone/README.md) for detailed instructions.

### Option 2: Ansible Deployment

Ideal for multiple hosts or infrastructure automation:

```bash
cd ansible-deployment/
./quick-start.sh
```

Or use the Makefile for more control:

```bash
cd ansible-deployment/
make help     # See all available commands
make deploy   # Deploy to all hosts
make verify   # Verify configuration
```

See the [Ansible README](ansible-deployment/README.md) for complete documentation.

## 🔧 What This Does

LLDP uses the multicast MAC address `01:80:c2:00:00:0e`, which is part of the reserved IEEE 802.1D range. Linux bridges filter these frames by default, preventing network topology discovery. This solution:

1. Modifies the bridge's `group_fwd_mask` parameter (sets bit 14 = 0x4000)
2. Enables LLDP frame forwarding across bridge interfaces
3. Persists the configuration across reboots using systemd
4. Works with all Proxmox bridge interfaces (vmbr0, vmbr1, etc.)

## 📋 Features

- ✅ **Persistent configuration** - Survives reboots
- ✅ **Automatic discovery** - Configures all bridge interfaces
- ✅ **Systemd integration** - Native Linux service
- ✅ **Comprehensive logging** - Track all operations
- ✅ **Two deployment methods** - Choose what works for you
- ✅ **Production ready** - Error handling and verification
- ✅ **Easy uninstallation** - Clean removal available

## 🧪 Compatibility

- **Proxmox VE:** 7.x, 8.x and newer
- **Linux Kernel:** Any recent kernel with bridge support
- **Ansible:** 2.9+ (for Ansible deployment method only)

## 📚 Documentation

- **[standalone/README.md](standalone/README.md)** - Complete standalone installation guide
- **[ansible-deployment/README.md](ansible-deployment/README.md)** - Ansible deployment overview
- **[ansible-deployment/README_ANSIBLE.md](ansible-deployment/README_ANSIBLE.md)** - Comprehensive Ansible documentation
- **[GIT_REPO_UPDATE_GUIDE.md](GIT_REPO_UPDATE_GUIDE.md)** - Repository update instructions

## 🔍 Verification

After installation, verify LLDP forwarding is enabled:

```bash
# Check service status
sudo systemctl status lldp-bridge-forwarding

# Verify bridge configuration (should show 0x4000 or higher)
cat /sys/class/net/vmbr0/bridge/group_fwd_mask

# View LLDP neighbors (if lldpd installed)
sudo apt-get install lldpd
sudo lldpctl
```

## 🎯 Use Cases

- **Network Topology Discovery** - See how Proxmox hosts connect to switches
- **Cable Tracking** - Identify physical port connections
- **Network Documentation** - Automated network mapping
- **Troubleshooting** - Verify physical layer connectivity
- **Compliance** - Meet requirements for network visibility

## 📝 License

Copyright (c) 2025 Darren Soothill

This script is provided as-is without warranty. Use at your own risk.

## 👤 Author

**Darren Soothill**
Website: [soothill.io](https://soothill.io)

## 🔗 Quick Links

- [Standalone Installation →](standalone/)
- [Ansible Deployment →](ansible-deployment/)
- [Troubleshooting Guide →](standalone/README.md#troubleshooting)
- [Advanced Configuration →](standalone/README.md#advanced-configuration)

---

**Choose your deployment method and get started!** 🚀
