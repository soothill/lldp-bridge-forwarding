#!/bin/bash
#
# LLDP Bridge Forwarding - Quick Start Script
# Author: Darren Soothill (soothill.io)
#
# This script helps you get started quickly with Ansible deployment

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}LLDP Bridge Forwarding - Quick Start${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Ansible is installed
echo -e "${BLUE}Checking prerequisites...${NC}"
if ! command -v ansible &> /dev/null; then
    echo -e "${RED}✗ Ansible is not installed${NC}"
    echo ""
    echo "Please install Ansible first:"
    echo ""
    echo "  Ubuntu/Debian:"
    echo "    sudo apt update && sudo apt install ansible"
    echo ""
    echo "  RHEL/CentOS/Rocky:"
    echo "    sudo dnf install ansible"
    echo ""
    echo "  macOS:"
    echo "    brew install ansible"
    echo ""
    exit 1
else
    echo -e "${GREEN}✓ Ansible installed:${NC} $(ansible --version | head -n1 | cut -d' ' -f2)"
fi

# Check if required files exist
echo -e "${BLUE}Checking required files...${NC}"
REQUIRED_FILES=("deploy-lldp-forwarding.yml" "inventory.yml" "ansible.cfg")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
        echo -e "${RED}✗ Missing: $file${NC}"
    else
        echo -e "${GREEN}✓ Found: $file${NC}"
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo -e "${RED}Some required files are missing!${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Setting up inventory...${NC}"

# Check if inventory has been customized
if grep -q "192.168.1.10" inventory.yml; then
    echo -e "${YELLOW}⚠ Warning: inventory.yml still has default IP address${NC}"
    echo ""
    read -p "Enter your Proxmox host IP address: " PROXMOX_IP
    read -p "Enter SSH username (default: root): " SSH_USER
    SSH_USER=${SSH_USER:-root}
    
    # Create customized inventory
    cat > inventory.yml <<EOF
---
# LLDP Bridge Forwarding - Ansible Inventory
proxmox:
  hosts:
    pve01:
      ansible_host: ${PROXMOX_IP}
      ansible_user: ${SSH_USER}
EOF
    
    echo -e "${GREEN}✓ Inventory updated${NC}"
else
    echo -e "${GREEN}✓ Inventory appears to be customized${NC}"
fi

echo ""
echo -e "${BLUE}Testing connectivity...${NC}"

# Test SSH connectivity
if ansible -i inventory.yml proxmox -m ping &> /dev/null; then
    echo -e "${GREEN}✓ Successfully connected to Proxmox host(s)${NC}"
else
    echo -e "${YELLOW}⚠ Unable to connect to Proxmox host(s)${NC}"
    echo ""
    echo "This could be due to:"
    echo "  - SSH key not configured"
    echo "  - Incorrect IP address"
    echo "  - Firewall blocking connection"
    echo ""
    read -p "Do you want to continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}What would you like to do?${NC}"
echo ""
echo "1) Test connection (ping all hosts)"
echo "2) Preview deployment (check mode - dry run)"
echo "3) Deploy LLDP forwarding"
echo "4) Verify existing deployment"
echo "5) View Makefile targets"
echo "6) Exit"
echo ""
read -p "Select an option [1-6]: " OPTION

case $OPTION in
    1)
        echo ""
        echo -e "${BLUE}Testing connection...${NC}"
        ansible -i inventory.yml proxmox -m ping
        ;;
    2)
        echo ""
        echo -e "${BLUE}Running in check mode (no changes will be made)...${NC}"
        ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --check
        ;;
    3)
        echo ""
        echo -e "${YELLOW}This will deploy LLDP bridge forwarding to your Proxmox host(s).${NC}"
        read -p "Are you sure you want to continue? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Deploying...${NC}"
            ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml
            echo ""
            echo -e "${GREEN}Deployment complete!${NC}"
            echo ""
            echo "To verify the deployment:"
            echo "  make verify"
            echo ""
            echo "To check service status:"
            echo "  make status"
        else
            echo "Deployment cancelled"
        fi
        ;;
    4)
        echo ""
        echo -e "${BLUE}Verifying deployment...${NC}"
        ansible-playbook -i inventory.yml deploy-lldp-forwarding.yml --tags verify
        ;;
    5)
        echo ""
        echo -e "${BLUE}Available Makefile targets:${NC}"
        make help
        ;;
    6)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Quick Start Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "  - Use 'make help' to see all available commands"
echo "  - Read README_ANSIBLE.md for detailed documentation"
echo "  - Use 'make deploy' for quick deployments"
echo "  - Use 'make verify' to check configurations"
echo ""
