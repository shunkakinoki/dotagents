.DEFAULT_GOAL := help

# ====================================================================================
# VARIABLES
# ====================================================================================

COMMANDS_SRC_DIR := $(dir $(lastword $(MAKEFILE_LIST)))commands
COMMANDS_TARGET_DIRS := $(HOME)/.cursor/commands $(HOME)/.claude/commands $(HOME)/.codex/prompts $(HOME)/.config/opencode/command $(HOME)/.config/amp/commands $(HOME)/.kilocode/workflows $(HOME)/Documents/Cline/Rules

SKILLS_SRC_DIR := $(dir $(lastword $(MAKEFILE_LIST)))skills
SKILLS_RULER_DIR := $(dir $(lastword $(MAKEFILE_LIST))).ruler/skills
SKILLS_TARGET_DIRS := $(HOME)/.claude/skills $(HOME)/.cursor/skills $(HOME)/.codex/skills $(HOME)/.roo/skills $(HOME)/.gemini/skills $(HOME)/.agents/skills $(HOME)/.vibe/skills

MCP_SRC := $(dir $(lastword $(MAKEFILE_LIST))).ruler/mcp.json
MCP_TARGET_DIRS := $(HOME)/.cursor $(HOME)/.claude $(HOME)/.codex

SKILL_REPOS := \
	anthropics/claude-plugins-official \
	better-auth/skills \
	trailofbits/skills \
	vercel-labs/agent-skills

# ====================================================================================
# ROOT TARGETS
# ====================================================================================

.PHONY: sync
sync: prepare ## Sync project commands, skills, and MCP configuration to assistant-specific directories.
	@make commands-sync
	@make skills-install
	@make skills-sync
	@make mcp-sync

.PHONY: prepare
prepare: ## Prepare the project for development.
	@make commands-copy
	@make skills-copy

# ====================================================================================
# COMMANDS
# ====================================================================================


.PHONY: commands-sync
commands-sync: ## Sync project commands to assistant-specific directories (overwrites, preserves other files).
	@for target in $(COMMANDS_TARGET_DIRS); do \
		if mkdir -p $$target && rsync -a $(COMMANDS_SRC_DIR)/ $$target/; then \
			echo "Synced $(COMMANDS_SRC_DIR) → $$target"; \
		else \
			echo "Failed syncing $(COMMANDS_SRC_DIR) → $$target"; \
			exit 1; \
		fi; \
	done

.PHONY: commands-copy
commands-copy: ## Copy commands to .ruler directory.
	@cp $(COMMANDS_SRC_DIR)/*.md $(dir $(lastword $(MAKEFILE_LIST))).ruler/

# ====================================================================================
# SKILLS
# ====================================================================================

.PHONY: skills-install
skills-install: ## Install skills from external repositories using bunx.
	@for repo in $(SKILL_REPOS); do \
		echo "Installing skills from $$repo..."; \
		if bunx skills add $$repo --global --yes; then \
			echo "✓ Installed $$repo"; \
		else \
			echo "✗ Failed to install $$repo"; \
			exit 1; \
		fi; \
	done
	@echo "All external skills installed successfully."

.PHONY: skills-install-repo
skills-install-repo: ## Install a single skill repo. Usage: make skills-install-repo REPO=owner/repo
	@if [ -z "$(REPO)" ]; then \
		echo "Error: REPO is required. Usage: make skills-install-repo REPO=owner/repo"; \
		exit 1; \
	fi
	@echo "Installing skills from $(REPO)..."
	@bunx skills add $(REPO) --global --yes
	@echo "✓ Installed $(REPO)"

.PHONY: skills-copy
skills-copy: ## Copy skills from root to .ruler/skills directory (overwrites, preserves other files).
	@rsync -a $(SKILLS_SRC_DIR)/ $(SKILLS_RULER_DIR)/
	@echo "Synced $(SKILLS_SRC_DIR) → $(SKILLS_RULER_DIR)"

.PHONY: skills-sync
skills-sync: ## Sync Ruler skills to agent-specific directories (preserves externally installed skills).
	@for target in $(SKILLS_TARGET_DIRS); do \
		if mkdir -p $$target && rsync -a $(SKILLS_RULER_DIR)/ $$target/; then \
			echo "Synced $(SKILLS_RULER_DIR) → $$target"; \
		else \
			echo "Failed syncing $(SKILLS_RULER_DIR) → $$target"; \
			exit 1; \
		fi; \
	done

# ====================================================================================
# MCP
# ====================================================================================

.PHONY: mcp-sync
mcp-sync: ## Sync MCP configuration from .ruler/mcp.json to CLI tools.
	@if [ ! -f $(MCP_SRC) ]; then \
		echo "Error: $(MCP_SRC) not found"; \
		exit 1; \
	fi
	@for target in $(MCP_TARGET_DIRS); do \
		if mkdir -p $$target && cp $(MCP_SRC) $$target/mcp.json; then \
			echo "Synced $(MCP_SRC) → $$target/mcp.json"; \
		else \
			echo "Failed syncing $(MCP_SRC) → $$target/mcp.json"; \
			exit 1; \
		fi; \
	done

# ====================================================================================
# HELP
# ====================================================================================

ifeq ($(DOTAGENTS_SKIP_HELP),)
.PHONY: help
help: ## Show this help message.
	@echo "Usage: make <target>"
	@echo
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
endif
