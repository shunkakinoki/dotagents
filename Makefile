.DEFAULT_GOAL := help

# ====================================================================================
# VARIABLES
# ====================================================================================

COMMANDS_SRC_DIR := $(dir $(lastword $(MAKEFILE_LIST)))commands
COMMANDS_TARGET_DIRS := $(HOME)/.cursor/commands $(HOME)/.claude/commands $(HOME)/.codex/prompts $(HOME)/.config/opencode/command $(HOME)/.config/amp/commands $(HOME)/.kilocode/workflows $(HOME)/Documents/Cline/Rules

RULES_SRC_DIR := $(dir $(lastword $(MAKEFILE_LIST)))rules
RULES_TARGET_DIR := $(dir $(lastword $(MAKEFILE_LIST))).ruler

SKILLS_SRC_DIR := $(dir $(lastword $(MAKEFILE_LIST)))skills
SKILLS_RULER_DIR := $(dir $(lastword $(MAKEFILE_LIST))).ruler/skills
SKILLS_TARGET_DIRS := $(HOME)/.claude/skills $(HOME)/.cursor/skills $(HOME)/.codex/skills $(HOME)/.roo/skills $(HOME)/.gemini/skills $(HOME)/.agents/skills $(HOME)/.vibe/skills

MCP_SRC := $(dir $(lastword $(MAKEFILE_LIST))).ruler/mcp.json
MCP_TARGET_DIRS := $(HOME)/.cursor $(HOME)/.claude $(HOME)/.codex

DOTDIRS := .agent .agents .amazonq .augment .claude .codex .cursor .gemini .idx .junie .kilocode .kiro .opencode .openhands .pi .qwen .roo .skillz .trae .vibe .vscode .windsurf .zed

SKILLS_FILE := $(dir $(lastword $(MAKEFILE_LIST)))SKILLS.txt
SKILL_REPOS := $(shell cat $(SKILLS_FILE) 2>/dev/null)

# ====================================================================================
# ROOT TARGETS
# ====================================================================================

.PHONY: sync
sync: ruler-prepare ## Sync project commands, skills, and MCP configuration to assistant-specific directories.
	@make commands-sync
	@make skills-install
	@make skills-sync
	@make mcp-sync
	@make ruler-apply-global
	@make ruler-dotdirs-sync

.PHONY: ruler-prepare
ruler-prepare: ## Prepare the project for development.
	@make ruler-commands-copy
	@make ruler-rules-copy
	@make ruler-skills-copy

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

.PHONY: ruler-commands-copy
ruler-commands-copy: ## Copy commands to .ruler directory.
	@cp $(COMMANDS_SRC_DIR)/*.md $(dir $(lastword $(MAKEFILE_LIST))).ruler/

# ====================================================================================
# RULES
# ====================================================================================

.PHONY: ruler-rules-copy
ruler-rules-copy: ## Copy rules to .ruler directory.
	@rsync -a $(RULES_SRC_DIR)/ $(RULES_TARGET_DIR)/
	@echo "Synced $(RULES_SRC_DIR) → $(RULES_TARGET_DIR)"

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

.PHONY: ruler-skills-copy
ruler-skills-copy: ## Copy skills from root to .ruler/skills directory (overwrites, preserves other files).
	@rsync -a $(SKILLS_SRC_DIR)/ $(SKILLS_RULER_DIR)/
	@echo "Synced $(SKILLS_SRC_DIR) → $(SKILLS_RULER_DIR)"

.PHONY: skills-sync
skills-sync: ## Sync root skills to agent-specific directories (preserves externally installed skills).
	@for target in $(SKILLS_TARGET_DIRS); do \
		if mkdir -p $$target && rsync -a $(SKILLS_SRC_DIR)/ $$target/; then \
			echo "Synced $(SKILLS_SRC_DIR) → $$target"; \
		else \
			echo "Failed syncing $(SKILLS_SRC_DIR) → $$target"; \
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
# RULER GLOBAL
# ====================================================================================

.PHONY: ruler-apply-global
ruler-apply-global: ruler-prepare ## Apply Ruler outputs to global paths.
	@bash -c 'set -e; \
		root="$$(pwd)"; \
		ruler_home="$$HOME/.ruler"; \
		rsync -a "$$root/.ruler/" "$$ruler_home/"; \
		bunx @intellectronica/ruler apply --project-root "$$HOME" --config "$$ruler_home/ruler.toml" --local-only'

.PHONY: ruler-dotdirs-sync
ruler-dotdirs-sync: ## Sync repo dot directories to $HOME equivalents.
	@bash -c 'set -e; \
		root="$$(pwd)"; \
		dirs="$(DOTDIRS)"; \
		for d in $$dirs; do \
			src="$$root/$$d"; \
			target="$$HOME/$$d"; \
			if [ -d "$$src" ]; then \
				mkdir -p "$$target"; \
				rsync -a "$$src/" "$$target/"; \
				echo "Synced $$src → $$target"; \
			fi; \
		done'

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
