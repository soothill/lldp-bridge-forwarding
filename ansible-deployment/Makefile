# LLDP Bridge Forwarding - Ansible Makefile
# Author: Darren Soothill (soothill.io)
#
# Common operations for deploying LLDP bridge forwarding to Proxmox hosts

.PHONY: help ping check deploy verify uninstall status clean

# Default inventory file
INVENTORY ?= inventory.yml
PLAYBOOK = deploy-lldp-forwarding.yml
LIMIT ?= all

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)LLDP Bridge Forwarding - Ansible Deployment$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Examples:$(NC)"
	@echo "  make ping                    # Test connectivity to all hosts"
	@echo "  make deploy                  # Deploy to all hosts"
	@echo "  make deploy LIMIT=pve01      # Deploy to specific host"
	@echo "  make verify                  # Verify deployment"
	@echo "  make uninstall               # Remove from all hosts"
	@echo ""

ping: ## Test connectivity to Proxmox hosts
	@echo "$(BLUE)Testing connectivity to Proxmox hosts...$(NC)"
	ansible -i $(INVENTORY) proxmox -m ping

check: ## Run playbook in check mode (dry-run)
	@echo "$(BLUE)Running playbook in check mode...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --check --limit $(LIMIT)

deploy: ## Deploy LLDP forwarding to Proxmox hosts
	@echo "$(BLUE)Deploying LLDP bridge forwarding...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --limit $(LIMIT)

deploy-verbose: ## Deploy with verbose output
	@echo "$(BLUE)Deploying LLDP bridge forwarding (verbose)...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --limit $(LIMIT) -vv

verify: ## Verify LLDP forwarding configuration
	@echo "$(BLUE)Verifying LLDP forwarding configuration...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --tags verify --limit $(LIMIT)

uninstall: ## Uninstall LLDP forwarding from hosts
	@echo "$(RED)Uninstalling LLDP bridge forwarding...$(NC)"
	@read -p "Are you sure you want to uninstall? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --tags uninstall --limit $(LIMIT); \
	else \
		echo "$(YELLOW)Uninstall cancelled$(NC)"; \
	fi

status: ## Check service status on all hosts
	@echo "$(BLUE)Checking service status...$(NC)"
	ansible -i $(INVENTORY) proxmox -a "systemctl status lldp-bridge-forwarding" --limit $(LIMIT) || true

logs: ## View recent log entries from all hosts
	@echo "$(BLUE)Fetching recent logs...$(NC)"
	ansible -i $(INVENTORY) proxmox -a "tail -20 /var/log/lldp-bridge-forward.log" --limit $(LIMIT) || true

bridges: ## Show bridge configurations on all hosts
	@echo "$(BLUE)Checking bridge configurations...$(NC)"
	@ansible -i $(INVENTORY) proxmox -m shell -a "for br in /sys/class/net/*/bridge; do iface=\$$(basename \$$(dirname \$$br)); mask=\$$(cat \$$br/group_fwd_mask 2>/dev/null || echo '0x0'); echo \"\$$iface: \$$mask\"; done" --limit $(LIMIT)

setup: ## Setup Ansible environment and check requirements
	@echo "$(BLUE)Checking Ansible setup...$(NC)"
	@which ansible >/dev/null 2>&1 || (echo "$(RED)Ansible not found! Please install ansible.$(NC)" && exit 1)
	@echo "$(GREEN)✓ Ansible installed:$(NC) $$(ansible --version | head -n1)"
	@test -f $(INVENTORY) || (echo "$(RED)Inventory file not found: $(INVENTORY)$(NC)" && exit 1)
	@echo "$(GREEN)✓ Inventory file found:$(NC) $(INVENTORY)"
	@test -f $(PLAYBOOK) || (echo "$(RED)Playbook not found: $(PLAYBOOK)$(NC)" && exit 1)
	@echo "$(GREEN)✓ Playbook file found:$(NC) $(PLAYBOOK)"
	@echo "$(GREEN)Setup complete!$(NC)"

lint: ## Lint the playbook with ansible-lint
	@echo "$(BLUE)Linting playbook...$(NC)"
	@which ansible-lint >/dev/null 2>&1 || (echo "$(YELLOW)ansible-lint not installed, skipping...$(NC)" && exit 0)
	ansible-lint $(PLAYBOOK)

syntax: ## Check playbook syntax
	@echo "$(BLUE)Checking playbook syntax...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --syntax-check

test: syntax lint ## Run syntax check and linting

list-hosts: ## List all hosts in inventory
	@echo "$(BLUE)Hosts in inventory:$(NC)"
	ansible -i $(INVENTORY) proxmox --list-hosts

list-tasks: ## List all tasks in playbook
	@echo "$(BLUE)Tasks in playbook:$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --list-tasks

facts: ## Gather facts from all hosts
	@echo "$(BLUE)Gathering facts...$(NC)"
	ansible -i $(INVENTORY) proxmox -m setup --limit $(LIMIT) | grep -E "ansible_hostname|ansible_distribution|ansible_kernel"

clean: ## Remove temporary files and caches
	@echo "$(BLUE)Cleaning up...$(NC)"
	rm -rf /tmp/ansible_facts
	rm -f ansible.log
	rm -f *.retry
	@echo "$(GREEN)Cleanup complete$(NC)"

# Installation helpers
install-ansible-debian: ## Install Ansible on Debian/Ubuntu
	@echo "$(BLUE)Installing Ansible on Debian/Ubuntu...$(NC)"
	sudo apt update
	sudo apt install -y ansible

install-ansible-rhel: ## Install Ansible on RHEL/CentOS/Rocky
	@echo "$(BLUE)Installing Ansible on RHEL/CentOS/Rocky...$(NC)"
	sudo dnf install -y ansible

install-ansible-macos: ## Install Ansible on macOS
	@echo "$(BLUE)Installing Ansible on macOS...$(NC)"
	brew install ansible

# Examples with specific scenarios
example-single-host: ## Example: Deploy to single host
	@echo "$(YELLOW)Example: Deploy to single host$(NC)"
	@echo "make deploy LIMIT=pve01"

example-check-before-deploy: ## Example: Check before deploying
	@echo "$(YELLOW)Example: Check then deploy$(NC)"
	@echo "make check && make deploy"

example-parallel: ## Example: Deploy in parallel
	@echo "$(YELLOW)Example: Deploy with high parallelism$(NC)"
	@echo "ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --forks 20"

# Default target
.DEFAULT_GOAL := help
