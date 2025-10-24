# LLDP Bridge Forwarding - Ansible Deployment

Automated deployment of LLDP bridge forwarding configuration to Proxmox VE hosts using Ansible.

**Author:** Darren Soothill (soothill.io)

## Overview

This Ansible playbook automates the deployment, configuration, and management of LLDP (Link Layer Discovery Protocol) forwarding on Linux bridge interfaces used by Proxmox VE. It provides:

- Automated deployment to single or multiple Proxmox hosts
- Systemd service configuration for persistence across reboots
- Flexible bridge targeting (all bridges or specific ones)
- Verification and status checking
- Easy uninstallation

## Prerequisites

### Control Node (where you run Ansible)

```bash
# Install Ansible
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# RHEL/CentOS/Rocky
sudo dnf install ansible

# macOS
brew install ansible

# Verify installation
ansible --version
```

### Target Hosts (Proxmox servers)

- Proxmox VE 7.x or 8.x
- SSH access with root or sudo privileges
- Python 3 installed (usually pre-installed on Proxmox)

## Quick Start

### 1. Setup Ansible Files

```bash
# Create project directory
mkdir lldp-ansible && cd lldp-ansible

# Copy the following files:
# - deploy-lldp-forwarding.yml
# - inventory.yml
# - ansible.cfg
# - group_vars/proxmox.yml
```

### 2. Configure Inventory

Edit `inventory.yml` with your Proxmox host details:

```yaml
proxmox:
  hosts:
    pve01:
      ansible_host: 192.168.1.10
      ansible_user: root
```

### 3. Test Connectivity

```bash
# Ping all hosts
ansible -i inventory.yml proxmox -m ping

# Check Python version
ansible -i inventory.yml proxmox -m setup -a "filter=ansible_python_version"
```

### 4. Deploy

```bash
# Deploy to all Proxmox hosts
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml

# Deploy to specific host
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --limit pve01

# Dry run (check mode)
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --check
```

## Configuration Options

### Inventory Variables

Configure in `inventory.yml` or `group_vars/proxmox.yml`:

#### Target Specific Bridges

```yaml
proxmox:
  hosts:
    pve01:
      ansible_host: 192.168.1.10
  vars:
    lldp_target_bridges:
      - vmbr0
      - vmbr1
```

If `lldp_target_bridges` is not defined, all bridges will be configured automatically.

#### Custom LLDP Mask

```yaml
# Enable LLDP only (default)
lldp_mask: "0x4000"

# Enable Cisco Discovery Protocol (CDP)
lldp_mask: "0x8000"

# Enable both LLDP and CDP
lldp_mask: "0xC000"
```

#### Custom Paths

```yaml
lldp_install_path: /usr/local/bin
lldp_log_file: /var/log/lldp-bridge-forward.log
lldp_service_name: lldp-bridge-forwarding
```

## Advanced Usage

### Deploy to Multiple Clusters

```yaml
# inventory.yml
all:
  children:
    datacenter1:
      hosts:
        pve01:
          ansible_host: 10.0.1.10
        pve02:
          ansible_host: 10.0.1.11
      vars:
        lldp_target_bridges:
          - vmbr0
          - vmbr1
    
    datacenter2:
      hosts:
        pve03:
          ansible_host: 10.0.2.10
        pve04:
          ansible_host: 10.0.2.11
      vars:
        lldp_target_bridges:
          - vmbr0
          - vmbr2
```

Deploy to specific datacenter:
```bash
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --limit datacenter1
```

### Verification Only

```bash
# Run only verification tasks
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --tags verify
```

### Parallel Execution

```bash
# Deploy to 10 hosts in parallel
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --forks 10
```

### Verbose Output

```bash
# Increase verbosity for troubleshooting
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml -v   # verbose
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml -vv  # more verbose
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml -vvv # debug
```

## Uninstallation

```bash
# Uninstall from all hosts
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --tags uninstall

# Uninstall from specific host
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --tags uninstall --limit pve01
```

This will:
- Stop and disable the systemd service
- Remove the script and service files
- Remove the log file
- Reload systemd daemon

**Note:** Bridge masks will revert to default after the next reboot.

## Playbook Structure

```
.
├── ansible.cfg                      # Ansible configuration
├── inventory.yml                    # Host inventory
├── deploy-lldp-forwarding.yml      # Main playbook
├── group_vars/
│   └── proxmox.yml                 # Group variables
└── README_ANSIBLE.md               # This file
```

## Playbook Tasks

The playbook performs the following operations:

1. **Pre-flight checks**
   - Verify Linux operating system
   - Discover bridge interfaces
   - Display configuration summary

2. **Installation**
   - Deploy LLDP forwarding script
   - Create systemd service
   - Enable and start service
   - Verify configuration

3. **Verification**
   - Check service status
   - Verify LLDP forwarding on each bridge
   - Display log entries

4. **Uninstallation** (with --tags uninstall)
   - Stop service
   - Remove all files
   - Reload systemd

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH connection manually
ssh root@192.168.1.10

# Use password authentication
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --ask-pass

# Use specific SSH key
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml \
  --private-key ~/.ssh/proxmox_key
```

### Permission Issues

```bash
# Use sudo with password
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml \
  --ask-become-pass

# Use different become method
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml \
  -e "ansible_become_method=su"
```

### Python Not Found

```bash
# Specify Python interpreter
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml \
  -e "ansible_python_interpreter=/usr/bin/python3"
```

### Service Fails to Start

Check the service status on the target host:
```bash
ssh root@pve01
systemctl status lldp-bridge-forwarding
journalctl -u lldp-bridge-forwarding -n 50
```

### Verify Deployment

```bash
# Check bridge configuration
ansible -i inventory.yml proxmox -a "cat /sys/class/net/vmbr0/bridge/group_fwd_mask"

# Check service status
ansible -i inventory.yml proxmox -a "systemctl status lldp-bridge-forwarding"

# View logs
ansible -i inventory.yml proxmox -a "tail -20 /var/log/lldp-bridge-forward.log"
```

## Integration with Existing Automation

### AWX/Ansible Tower

1. Import the playbook into your project
2. Create inventory in AWX/Tower
3. Create job template with the playbook
4. Schedule or trigger deployments

### CI/CD Pipeline

```yaml
# Example GitLab CI
deploy_lldp:
  stage: deploy
  script:
    - ansible-playbook -i production.yml deploy-lldp-forwarding.yml
  only:
    - master
  when: manual
```

### Ansible Pull (Self-Service)

```bash
# Run on Proxmox host directly
ansible-pull -U https://your-repo/lldp-ansible.git deploy-lldp-forwarding.yml
```

## Security Considerations

1. **SSH Keys**: Use SSH key authentication instead of passwords
2. **Vault**: Encrypt sensitive variables with ansible-vault
3. **Sudo**: Configure passwordless sudo for automation users
4. **Audit**: Enable Ansible logging for audit trails

### Example: Using Ansible Vault

```bash
# Encrypt sensitive variables
ansible-vault encrypt group_vars/proxmox.yml

# Run playbook with vault
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --ask-vault-pass

# Use vault password file
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml \
  --vault-password-file ~/.vault_pass
```

## Best Practices

1. **Test First**: Always test on a non-production host first
2. **Check Mode**: Use `--check` for dry runs
3. **Limit Scope**: Use `--limit` when testing or for partial deployments
4. **Version Control**: Keep your inventory and variables in git
5. **Documentation**: Document any custom configurations
6. **Backup**: Keep backups of original configurations

## Example Workflows

### Initial Deployment

```bash
# 1. Test connectivity
ansible -i inventory.yml proxmox -m ping

# 2. Check current bridge status
ansible -i inventory.yml proxmox -m shell \
  -a "cat /sys/class/net/vmbr*/bridge/group_fwd_mask"

# 3. Deploy with check mode
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --check

# 4. Deploy for real
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml

# 5. Verify deployment
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --tags verify
```

### Rolling Update

```bash
# Update hosts one at a time
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --serial 1
```

### Emergency Rollback

```bash
# Quickly uninstall from all hosts
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml \
  --tags uninstall --forks 20
```

## Performance Tips

- Use `ansible_ssh_pipelining = True` for faster execution
- Increase `forks` value for parallel execution
- Enable fact caching to reduce gathering time
- Use `--limit` to target specific hosts

## Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Proxmox VE Network Configuration](https://pve.proxmox.com/wiki/Network_Configuration)
- [LLDP Protocol Documentation](https://en.wikipedia.org/wiki/Link_Layer_Discovery_Protocol)
- [Systemd Service Management](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

## Support

For issues or questions:
- Check the main project README
- Review Ansible logs: `./ansible.log` (if enabled)
- Visit: [soothill.io](https://soothill.io)

## License

Copyright (c) 2025 Darren Soothill

This playbook is provided as-is without warranty. Use at your own risk.
