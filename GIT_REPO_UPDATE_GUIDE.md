# Update Your Local Git Repository

## Overview

Your local git repository at `/Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding` needs to be updated with:

1. ✅ Ansible deployment playbook
2. ✅ Comprehensive documentation
3. ✅ Updated README
4. ✅ Additional utilities

## Quick Update (Recommended)

### Step 1: Download and Extract

```bash
# Download lldp-bridge-forwarding-complete.tar.gz
# Extract it to your Downloads or any working directory
cd ~/Downloads
tar -xzf lldp-bridge-forwarding-complete.tar.gz
cd lldp-bridge-forwarding-complete
```

### Step 2: Run the Sync Script

```bash
# Make the sync script executable
chmod +x sync-to-git-repo.sh

# Run the interactive sync script
./sync-to-git-repo.sh
```

The script will:
- ✅ Automatically find your git repository
- ✅ Create a backup before making changes
- ✅ Sync all new files
- ✅ Preserve your .git directory
- ✅ Give you next steps for committing

### Step 3: Review and Commit

```bash
cd /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding
git status
git diff  # Review changes
git add .
git commit -m "Add Ansible deployment and comprehensive documentation

- Add complete Ansible playbook for multi-host deployment
- Add Makefile with convenient deployment targets
- Add interactive quick-start scripts
- Add comprehensive documentation suite
- Add verification and status checking tools
- Update README with both standalone and Ansible options
- Add group_vars and host_vars for flexible configuration"

git push origin main
```

---

## Manual Update (Alternative)

If you prefer to do it manually:

### Option A: Using rsync

```bash
# 1. Backup your current repo
cp -r /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding \
     /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding_backup

# 2. Navigate to the extracted package
cd ~/Downloads/lldp-bridge-forwarding-complete

# 3. Sync files (excluding .git directory)
rsync -av --exclude='.git' \
     standalone/ \
     /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding/

# 4. Review changes
cd /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding
git status
```

### Option B: Using cp

```bash
# 1. Backup
cp -r /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding \
     /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding_backup

# 2. Copy all files except .git
cd ~/Downloads/lldp-bridge-forwarding-complete/standalone
cp -r * /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding/
cp .gitignore /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding/

# 3. Review changes
cd /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding
git status
```

---

## What's Being Added/Updated

### New Files (Ansible deployment):
```
/Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding/
├── deploy-lldp-forwarding.yml    (NEW - Main Ansible playbook)
├── inventory.yml                  (NEW - Host inventory template)
├── ansible.cfg                    (NEW - Ansible configuration)
├── Makefile                       (NEW - Convenient commands)
├── quick-start.sh                 (NEW - Interactive setup)
├── requirements.yml               (NEW - Ansible dependencies)
├── group_vars/
│   └── proxmox.yml               (NEW - Group variables)
└── host_vars/
    └── pve01.yml.example         (NEW - Per-host config example)
```

### Updated Files:
```
├── README.md                      (UPDATED - Now includes Ansible info)
└── (Existing standalone files remain unchanged)
```

### Existing Files (Unchanged):
```
├── enable-lldp-forwarding.sh
├── lldp-bridge-forwarding.service
├── install.sh
├── check-lldp-status.sh
├── LICENSE
└── .gitignore
```

---

## Verification Steps

After syncing, verify everything is correct:

```bash
cd /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding

# 1. Check git status
git status

# 2. Verify key files exist
ls -la deploy-lldp-forwarding.yml
ls -la Makefile
ls -la group_vars/proxmox.yml

# 3. Test Ansible syntax (if Ansible installed)
ansible-playbook deploy-lldp-forwarding.yml --syntax-check

# 4. Test Makefile
make help

# 5. Review README
cat README.md
```

---

## Suggested Commit Message

```
Add Ansible deployment and comprehensive documentation

This major update adds Ansible automation for multi-host deployments
while maintaining backward compatibility with standalone installations.

New Features:
- Complete Ansible playbook for automated deployment
- Makefile with convenient targets (deploy, verify, status, etc.)
- Interactive quick-start script for easy setup
- Group and host variable templates for flexible configuration
- Comprehensive Ansible documentation

Enhancements:
- Updated README with both deployment options
- Added requirements.yml for Ansible Galaxy dependencies
- Improved documentation structure
- Added configuration examples

The standalone scripts remain unchanged and fully functional.
Users can now choose between:
1. Standalone installation (existing method)
2. Ansible automation (new method for multi-host)

Closes: N/A
Related: Infrastructure automation initiative
```

---

## Alternative: Fresh Clone with New Content

If you want to start fresh:

```bash
# 1. Backup old repo
mv /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding \
   /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding_old

# 2. Copy standalone directory as new repo
cd ~/Downloads/lldp-bridge-forwarding-complete
cp -r standalone /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding

# 3. The standalone directory already has git initialized
cd /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding
git log  # Check existing commits

# 4. Add remote (if not already set)
git remote add origin git@github.com:YOUR_USERNAME/lldp-bridge-forwarding.git

# 5. Push
git push -u origin main
```

---

## Troubleshooting

### Issue: "rsync: command not found"

**Solution:** Use cp method instead or install rsync:
```bash
brew install rsync
```

### Issue: Git conflicts

**Solution:** 
```bash
# If you have uncommitted changes
git stash
# Then sync files
# Then restore your changes
git stash pop
```

### Issue: Want to see differences before committing

**Solution:**
```bash
git diff                    # See all changes
git diff README.md          # See specific file changes
git diff --cached          # See staged changes
```

### Issue: Made a mistake

**Solution:**
```bash
# Restore from backup
rm -rf /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding
cp -r /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding_backup \
     /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding

# Or use git
cd /Users/darrensoothill/Documents/GitHub/lldp-bridge-forwarding
git checkout .              # Discard all changes
git clean -fd              # Remove untracked files
```

---

## Post-Update Checklist

After updating your repository:

- [ ] Run `git status` to review changes
- [ ] Run `git diff` to see modifications
- [ ] Test that scripts are executable: `ls -la *.sh`
- [ ] Verify Ansible playbook syntax (if Ansible installed)
- [ ] Test Makefile: `make help`
- [ ] Review updated README.md
- [ ] Commit changes with descriptive message
- [ ] Push to remote repository
- [ ] Update repository description on GitHub (if applicable)
- [ ] Add topics/tags: `proxmox`, `lldp`, `networking`, `ansible`, `automation`

---

## Publishing Updates

After updating your local repo and pushing:

### Update Repository Description

On GitHub, update your repository with:

**Description:**
```
Enable LLDP forwarding on Proxmox bridge interfaces with persistent configuration. Includes both standalone scripts and Ansible automation for multi-host deployment.
```

**Topics:**
```
proxmox, lldp, networking, linux-bridge, systemd, ansible, automation, infrastructure
```

### Update GitHub README

The new README.md will automatically update on GitHub after you push.

---

## Need Help?

If you encounter any issues:

1. **Create a backup first** - Always backup before making changes
2. **Use the sync script** - It handles edge cases automatically
3. **Test locally** - Verify everything works before pushing
4. **Review changes** - Use `git diff` to see what changed

---

## Summary

**Easiest Method:**
1. Extract `lldp-bridge-forwarding-complete.tar.gz`
2. Run `./sync-to-git-repo.sh`
3. Follow the prompts
4. Commit and push

**Manual Method:**
1. Backup your repo
2. Use rsync or cp to copy files
3. Review with `git status`
4. Commit and push

Both methods preserve your git history and give you full control over the update process.
