# Git Repository Update Package

This package contains everything you need to update your local git repository at:
`/Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding`

## 🚀 Quick Update (3 Steps)

```bash
# 1. Extract this package
tar -xzf git-repo-update.tar.gz
cd git-repo-update

# 2. Run the sync script
./sync-to-git-repo.sh

# 3. Follow the prompts and commit
```

## 📦 Package Contents

```
git-repo-update/
├── sync-to-git-repo.sh           ⭐ RUN THIS - Interactive sync script
├── GIT_REPO_UPDATE_GUIDE.md      📖 Comprehensive update guide
│
├── standalone/                    🔧 All standalone files for git repo
│   ├── enable-lldp-forwarding.sh
│   ├── lldp-bridge-forwarding.service
│   ├── install.sh
│   ├── check-lldp-status.sh
│   ├── README.md
│   ├── LICENSE
│   └── .gitignore
│
└── ansible-deployment/            🤖 Optional: Ansible files
    ├── deploy-lldp-forwarding.yml
    ├── inventory.yml
    ├── ansible.cfg
    ├── Makefile
    ├── quick-start.sh
    └── ... (all Ansible files)
```

## 📋 What Gets Updated

### Core Repository (standalone/)
These files will be synced to your git repository:
- ✅ All existing standalone scripts (unchanged)
- ✅ Updated README.md (now includes Ansible info)
- ✅ LICENSE and .gitignore

### Optional: Ansible Deployment
If you want to add Ansible automation to your repository:
- Copy files from `ansible-deployment/` to your repo
- Creates a complete Ansible playbook structure
- Allows users to choose between standalone or Ansible deployment

## 🎯 Two Update Options

### Option 1: Standalone Only (Simpler)

Keep your repository focused on standalone scripts:

```bash
# Run sync script and choose option 1
./sync-to-git-repo.sh
```

Your repository will contain:
```
lldp-bridge-forwarding/
├── enable-lldp-forwarding.sh
├── lldp-bridge-forwarding.service
├── install.sh
├── check-lldp-status.sh
├── README.md
├── LICENSE
└── .gitignore
```

### Option 2: Include Ansible (Recommended)

Add Ansible automation alongside standalone scripts:

```bash
# 1. Run sync script for standalone files
./sync-to-git-repo.sh

# 2. Copy Ansible files
cd /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding
cp -r ~/path/to/git-repo-update/ansible-deployment/* .

# 3. Commit everything
git add .
git commit -m "Add Ansible deployment alongside standalone scripts"
```

Your repository will contain:
```
lldp-bridge-forwarding/
├── Standalone scripts (existing)
├── Ansible playbook files (new)
├── Makefile
├── group_vars/
├── host_vars/
└── Updated README.md
```

## 📝 Detailed Instructions

### Using the Sync Script (Easiest)

```bash
cd git-repo-update
./sync-to-git-repo.sh
```

The script will:
1. Locate your git repository
2. Create a backup automatically
3. Sync all files from standalone/
4. Preserve your .git directory
5. Show you what to commit

### Manual Update

```bash
# 1. Backup
cp -r /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding \
     /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding_backup

# 2. Sync files
rsync -av --exclude='.git' \
     standalone/ \
     /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding/

# 3. Optional: Add Ansible
cp -r ansible-deployment/* \
     /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding/

# 4. Review and commit
cd /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding
git status
git add .
git commit -m "Update with Ansible deployment and documentation"
git push origin main
```

## 🔍 What's New

### Updated Files:
- **README.md** - Now documents both standalone and Ansible deployment options

### New Ansible Files (if you choose to add them):
- **deploy-lldp-forwarding.yml** - Complete Ansible playbook
- **Makefile** - Convenient deployment commands (make deploy, make verify, etc.)
- **quick-start.sh** - Interactive Ansible setup
- **inventory.yml** - Host configuration template
- **ansible.cfg** - Ansible settings
- **requirements.yml** - Ansible dependencies
- **group_vars/** - Group-level configuration
- **host_vars/** - Per-host configuration examples

## ✅ Post-Update Checklist

After syncing:

```bash
cd /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding

# 1. Check what changed
git status
git diff

# 2. Verify scripts are executable
ls -la *.sh

# 3. If you added Ansible, test it
ansible-playbook deploy-lldp-forwarding.yml --syntax-check
make help

# 4. Commit your changes
git add .
git commit -m "Add Ansible deployment and comprehensive documentation"

# 5. Push to remote
git push origin main
```

## 📖 Full Documentation

For comprehensive instructions, see:
- **[GIT_REPO_UPDATE_GUIDE.md](GIT_REPO_UPDATE_GUIDE.md)** - Complete guide with troubleshooting

## 🎓 Suggested Commit Message

```
Add Ansible deployment and comprehensive documentation

- Add complete Ansible playbook for multi-host deployment
- Add Makefile with convenient deployment targets  
- Add interactive quick-start scripts
- Add group_vars and host_vars for flexible configuration
- Update README with both standalone and Ansible options
- Maintain backward compatibility with existing standalone scripts

Users can now choose between:
1. Standalone installation (existing method)
2. Ansible automation (new method for multi-host)
```

## 🆘 Need Help?

1. Read **GIT_REPO_UPDATE_GUIDE.md** for detailed instructions
2. The sync script includes a dry-run option (option 3)
3. Always creates backups automatically
4. All operations are safe and reversible

## 🌐 After Pushing

Update your GitHub repository:

**Description:**
```
Enable LLDP forwarding on Proxmox bridge interfaces with persistent configuration. 
Includes both standalone scripts and Ansible automation for multi-host deployment.
```

**Topics:**
`proxmox` `lldp` `networking` `linux-bridge` `systemd` `ansible` `automation` `infrastructure`

---

**Ready?** Run `./sync-to-git-repo.sh` to get started! 🚀
