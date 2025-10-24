# LLDP Bridge Forwarding - Repository Structure Guide

## Repository Overview

This repository contains LLDP bridge forwarding solutions for Proxmox VE, organized into two distinct deployment methods:

```
lldp-bridge-forwarding/
├── README.md                     # Main repository documentation
├── GIT_REPO_UPDATE_GUIDE.md     # This file
│
├── standalone/                   # Traditional bash script deployment
│   ├── enable-lldp-forwarding.sh
│   ├── lldp-bridge-forwarding.service
│   ├── install.sh
│   ├── check-lldp-status.sh
│   ├── README.md
│   ├── LICENSE
│   └── .gitignore
│
└── ansible-deployment/           # Ansible automation deployment
    ├── deploy-lldp-forwarding.yml
    ├── inventory.yml
    ├── ansible.cfg
    ├── Makefile
    ├── quick-start.sh
    ├── requirements.yml
    ├── README.md
    ├── README_ANSIBLE.md
    ├── group_vars/
    │   └── proxmox.yml
    └── host_vars/
        └── pve01.yml.example
```

## 📂 Directory Descriptions

### `standalone/` Directory

**Purpose:** Traditional bash script installation for individual Proxmox hosts

**Use when:**
- Installing on a single Proxmox host
- You prefer manual installation
- You don't have or want Ansible
- You're testing or learning
- Quick deployments needed

**Contents:**
- `enable-lldp-forwarding.sh` - Core script that modifies bridge forwarding masks
- `lldp-bridge-forwarding.service` - Systemd service unit for persistence
- `install.sh` - Automated installation wrapper script
- `check-lldp-status.sh` - Status verification utility
- `README.md` - Complete standalone documentation
- `LICENSE` - MIT License
- `.gitignore` - Git ignore rules

**Quick start:**
```bash
cd standalone/
sudo ./install.sh
```

**Documentation:** See [standalone/README.md](standalone/README.md)

---

### `ansible-deployment/` Directory

**Purpose:** Ansible-based automation for deploying to multiple Proxmox hosts

**Use when:**
- Managing multiple Proxmox hosts (cluster)
- Implementing Infrastructure as Code (IaC)
- Need repeatable, automated deployments
- Integrating with CI/CD pipelines
- Managing different configurations per host/group

**Contents:**
- `deploy-lldp-forwarding.yml` - Main Ansible playbook
- `inventory.yml` - Host inventory template (customize with your hosts)
- `ansible.cfg` - Ansible configuration settings
- `Makefile` - Convenient make targets (deploy, verify, status, etc.)
- `quick-start.sh` - Interactive setup wizard
- `requirements.yml` - Ansible Galaxy dependencies
- `README.md` - Quick reference guide
- `README_ANSIBLE.md` - Comprehensive Ansible documentation
- `group_vars/proxmox.yml` - Group-level variables
- `host_vars/pve01.yml.example` - Per-host configuration example

**Quick start:**
```bash
cd ansible-deployment/
./quick-start.sh
# or
make deploy
```

**Documentation:**
- Quick reference: [ansible-deployment/README.md](ansible-deployment/README.md)
- Full documentation: [ansible-deployment/README_ANSIBLE.md](ansible-deployment/README_ANSIBLE.md)

## 🎯 Choosing the Right Method

### Decision Matrix

| Scenario | Use `standalone/` | Use `ansible-deployment/` |
|----------|-------------------|---------------------------|
| Single Proxmox host | ✅ Recommended | ⚪ Optional |
| Multiple Proxmox hosts | ⚪ Manual effort | ✅ Recommended |
| No Ansible available | ✅ Required | ❌ Not possible |
| Infrastructure as Code | ⚪ Limited | ✅ Ideal |
| Quick test/demo | ✅ Fastest | ⚪ More setup |
| Production cluster | ⚪ Time-consuming | ✅ Best practice |
| CI/CD integration | ⚪ Difficult | ✅ Built-in |
| Configuration variance | ⚪ Manual edits | ✅ Variables |

### Can I Use Both?

**Yes!** The two methods are completely independent:

- Use **standalone** for your test environment
- Use **ansible-deployment** for production
- Both install the same LLDP forwarding functionality
- Both create the same systemd service
- Both use the same core script logic

---

## 🚀 Getting Started

### For Standalone Installation

1. Navigate to the standalone directory:
   ```bash
   cd standalone/
   ```

2. Review the README:
   ```bash
   cat README.md
   ```

3. Run the installer:
   ```bash
   sudo ./install.sh
   ```

4. Verify installation:
   ```bash
   sudo systemctl status lldp-bridge-forwarding
   ```

### For Ansible Deployment

1. Navigate to the ansible-deployment directory:
   ```bash
   cd ansible-deployment/
   ```

2. Review the documentation:
   ```bash
   cat README.md
   cat README_ANSIBLE.md
   ```

3. Configure your inventory:
   ```bash
   nano inventory.yml  # Add your Proxmox hosts
   ```

4. Run quick-start or deploy directly:
   ```bash
   ./quick-start.sh
   # or
   make deploy
   ```

5. Verify deployment:
   ```bash
   make verify
   make status
   ```

---

## 📝 Common Workflows

### Workflow 1: Fresh Repository Clone

If you're cloning this repository for the first time:

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/lldp-bridge-forwarding.git
cd lldp-bridge-forwarding

# Choose your method:
# Option A: Standalone
cd standalone/ && sudo ./install.sh

# Option B: Ansible
cd ansible-deployment/ && make deploy
```

### Workflow 2: Update Existing Installation

If you already have the standalone scripts installed and want to switch to Ansible:

```bash
# Your existing installation remains functional
# Simply use Ansible for future deployments

cd ansible-deployment/
nano inventory.yml  # Add all your hosts
make deploy         # Deploy to all hosts (including current one)
```

### Workflow 3: Contribute or Modify

If you want to modify the solution:

```bash
# Make changes in the appropriate directory
cd standalone/  # for standalone modifications
# or
cd ansible-deployment/  # for Ansible modifications

# Test your changes
# Commit and push
git add .
git commit -m "Your changes"
git push origin main
```

## 🔧 Troubleshooting

### General Issues

**Q: Which method should I use?**
- Single host → Use `standalone/`
- Multiple hosts → Use `ansible-deployment/`
- Not sure → Start with `standalone/` for testing

**Q: Can I use both methods?**
- Yes! They're independent and install the same service
- Test with standalone, deploy production with Ansible

**Q: Where's the documentation?**
- Main README: [README.md](README.md)
- Standalone: [standalone/README.md](standalone/README.md)
- Ansible quick: [ansible-deployment/README.md](ansible-deployment/README.md)
- Ansible full: [ansible-deployment/README_ANSIBLE.md](ansible-deployment/README_ANSIBLE.md)

### Standalone Issues

**Scripts not executable:**
```bash
cd standalone/
chmod +x *.sh
```

**Installation fails:**
```bash
# Check logs
sudo journalctl -u lldp-bridge-forwarding -n 50

# Verify bridges exist
ls -la /sys/class/net/*/bridge
```

**Service not persistent:**
```bash
sudo systemctl is-enabled lldp-bridge-forwarding
sudo systemctl enable lldp-bridge-forwarding
```

### Ansible Issues

**Ansible not installed:**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# macOS
brew install ansible
```

**Connection failures:**
```bash
# Test SSH connectivity
cd ansible-deployment/
ansible -i inventory.yml proxmox -m ping

# Use password auth
ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --ask-pass
```

**Inventory configuration:**
```bash
# Edit with your host details
nano inventory.yml

# Test connectivity before deploying
make ping
```

---

## 📚 Additional Resources

### Documentation Files

| File | Purpose |
|------|---------|
| [README.md](README.md) | Main repository overview and quick start |
| [GIT_REPO_UPDATE_GUIDE.md](GIT_REPO_UPDATE_GUIDE.md) | This file - repository structure guide |
| [standalone/README.md](standalone/README.md) | Complete standalone installation guide |
| [ansible-deployment/README.md](ansible-deployment/README.md) | Ansible quick reference |
| [ansible-deployment/README_ANSIBLE.md](ansible-deployment/README_ANSIBLE.md) | Comprehensive Ansible documentation |

### Quick Commands Reference

**Standalone:**
```bash
cd standalone/
sudo ./install.sh                           # Install
sudo systemctl status lldp-bridge-forwarding # Check status
sudo ./check-lldp-status.sh                 # Verify configuration
```

**Ansible:**
```bash
cd ansible-deployment/
make help      # Show all commands
make ping      # Test connectivity
make deploy    # Deploy to all hosts
make verify    # Verify configuration
make status    # Check service status
make bridges   # Show bridge configurations
```

---

## 🎓 Best Practices

### For Standalone Deployments

1. **Test first**: Run on a test host before production
2. **Verify bridges**: Check `/sys/class/net/*/bridge` exists
3. **Check logs**: Monitor `/var/log/lldp-bridge-forward.log`
4. **Service status**: Regularly verify with `systemctl status`

### For Ansible Deployments

1. **Version control**: Keep inventory and variables in git
2. **Test connectivity**: Always `make ping` before deploying
3. **Use dry-run**: Test with `--check` flag first
4. **Group variables**: Use `group_vars/` for shared config
5. **Host variables**: Use `host_vars/` for unique configs
6. **Staged rollouts**: Deploy to staging before production

---

## 📝 License

Copyright (c) 2025 Darren Soothill

This solution is provided as-is without warranty. Use at your own risk.

## 👤 Author

**Darren Soothill**
Website: [soothill.io](https://soothill.io)

---

## 🔗 Quick Links

- **[Main README](README.md)** - Repository overview
- **[Standalone Guide](standalone/README.md)** - Manual installation
- **[Ansible Guide](ansible-deployment/README_ANSIBLE.md)** - Automation deployment
- **Proxmox VE**: [Network Configuration](https://pve.proxmox.com/wiki/Network_Configuration)
- **LLDP Standard**: [IEEE 802.1AB](https://standards.ieee.org/standard/802_1AB-2016.html)

---

**Choose your deployment method and get started!** 🚀
