# LLDP Bridge Forwarding - Ansible Deployment

Automated deployment of LLDP bridge forwarding configuration to Proxmox VE hosts using Ansible.

**Author:** Darren Soothill (soothill.io)

## Quick Start

```bash
# 1. Extract the archive
tar -xzf lldp-ansible.tar.gz
cd lldp-ansible

# 2. Run the quick start script
chmod +x quick-start.sh
./quick-start.sh

# 3. Or use Make for common operations
make help
make deploy
```

## What's Included

```
lldp-ansible/
├── deploy-lldp-forwarding.yml    # Main Ansible playbook
├── inventory.yml                  # Host inventory (customize this!)
├── ansible.cfg                    # Ansible configuration
├── requirements.yml               # Ansible Galaxy requirements
├── Makefile                       # Convenient make targets
├── quick-start.sh                 # Interactive setup script
├── README_ANSIBLE.md              # Comprehensive documentation
├── group_vars/
│   └── proxmox.yml               # Group variables
└── host_vars/
    └── pve01.yml.example         # Per-host configuration example
```

## Prerequisites

- Ansible 2.9 or higher
- SSH access to Proxmox hosts (root or sudo)
- Python 3 on target hosts

## Installation

### Install Ansible

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install ansible
```

**RHEL/CentOS/Rocky:**
```bash
sudo dnf install ansible
```

**macOS:**
```bash
brew install ansible
```

## Configuration

### 1. Edit Inventory

Customize `inventory.yml` with your Proxmox host details:

```yaml
proxmox:
  hosts:
    pve01:
      ansible_host: 192.168.1.10
      ansible_user: root
    pve02:
      ansible_host: 192.168.1.11
      ansible_user: root
```

### 2. Configure Variables (Optional)

Edit `group_vars/proxmox.yml` to customize behavior:

```yaml
# Target specific bridges only
lldp_target_bridges:
  - vmbr0
  - vmbr1

# Or leave undefined to configure all bridges automatically
```

## Deployment

### Using Make (Recommended)

```bash
# See all available commands
make help

# Test connectivity
make ping

# Deploy to all hosts
make deploy

# Deploy to specific host
make deploy LIMIT=pve01

# Verify configuration
make verify

# Check service status
make status
```

### Using Ansible Directly

```bash
# Test connectivity
ansible -i inventory.yml proxmox -m ping

# Deploy
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml

# Dry run (no changes)
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --check

# Deploy to specific host
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --limit pve01

# Uninstall
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --tags uninstall
```

## Features

✓ **Automated deployment** to multiple Proxmox hosts  
✓ **Idempotent** - safe to run multiple times  
✓ **Flexible targeting** - configure all bridges or specific ones  
✓ **Systemd integration** - persistent across reboots  
✓ **Built-in verification** - checks configuration after deployment  
✓ **Easy uninstallation** - clean removal with single command  
✓ **Production-ready** - includes logging, error handling, and rollback  

## Advanced Usage

### Deploy to Multiple Environments

```yaml
# inventory.yml
all:
  children:
    production:
      hosts:
        pve01: { ansible_host: 10.0.1.10 }
        pve02: { ansible_host: 10.0.1.11 }
      vars:
        lldp_target_bridges: [vmbr0, vmbr1]
    
    staging:
      hosts:
        pve-staging: { ansible_host: 10.0.2.10 }
      vars:
        lldp_target_bridges: [vmbr0]
```

Deploy to production:
```bash
make deploy LIMIT=production
```

### Per-Host Configuration

Create `host_vars/pve01.yml`:
```yaml
lldp_target_bridges:
  - vmbr0
  - vmbr1
lldp_mask: "0xC000"  # Enable both LLDP and CDP
```

### Parallel Execution

```bash
# Deploy to 10 hosts simultaneously
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --forks 10
```

## Verification

After deployment, verify the configuration:

```bash
# Using Make
make verify
make status
make bridges

# Using Ansible directly
ansible -i inventory.yml proxmox -a "systemctl status lldp-bridge-forwarding"
ansible -i inventory.yml proxmox -a "cat /sys/class/net/vmbr0/bridge/group_fwd_mask"
```

Expected output for working configuration:
- Service status: **active (exited)**
- Bridge mask: **0x4000** or higher

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH manually
ssh root@192.168.1.10

# Use password authentication
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --ask-pass

# Use specific SSH key
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml \
  --private-key ~/.ssh/proxmox_key
```

### Service Not Starting

Check logs on the target host:
```bash
ssh root@pve01
systemctl status lldp-bridge-forwarding
journalctl -u lldp-bridge-forwarding -n 50
tail -20 /var/log/lldp-bridge-forward.log
```

### No Bridges Found

Verify bridges exist:
```bash
ansible -i inventory.yml proxmox -a "ls -la /sys/class/net/*/bridge" | grep -v failed
```

## Uninstallation

Remove LLDP forwarding from all hosts:

```bash
# Using Make (with confirmation)
make uninstall

# Using Ansible directly
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --tags uninstall

# For specific host
make uninstall LIMIT=pve01
```

## Integration

### AWX/Ansible Tower

1. Import playbook into project
2. Create inventory
3. Create job template
4. Schedule or trigger deployments

### CI/CD Pipeline

```yaml
# GitLab CI example
deploy_lldp:
  stage: deploy
  script:
    - ansible-playbook -i production.yml deploy-lldp-forwarding.yml
  only:
    - master
```

## Documentation

- **README_ANSIBLE.md** - Comprehensive Ansible documentation
- **Makefile** - Run `make help` for all commands
- **quick-start.sh** - Interactive setup guide

## Support

For detailed documentation, see `README_ANSIBLE.md`

For issues or questions:
- Visit: [soothill.io](https://soothill.io)
- Check the main project repository

## License

Copyright (c) 2025 Darren Soothill  
Licensed under MIT License

---

**Happy Automating!** 🚀
