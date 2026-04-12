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
SKILLS_TARGET_DIRS := $(HOME)/.claude/skills $(HOME)/.cursor/skills $(HOME)/.codex/skills $(HOME)/.roo/skills $(HOME)/.gemini/skills $(HOME)/.agents/skills $(HOME)/.vibe/skills $(HOME)/.config/opencode/skills
SKILLS_STATE_DIR := $(HOME)/.cache/dotagents/skills
SKILLS_MANIFEST_DIR := $(SKILLS_STATE_DIR)/manifests
SKILLS_SPEC_STATE_FILE := $(SKILLS_STATE_DIR)/skills.txt.normalized
SKILLS_EXTERNAL_SOURCE_DIR := $(HOME)/.agents/skills

MCP_SRC := $(dir $(lastword $(MAKEFILE_LIST))).ruler/mcp.json
MCP_TARGET_DIRS := $(HOME)/.cursor $(HOME)/.claude $(HOME)/.codex
MCP_SETTINGS_TARGETS := $(addsuffix /settings.local.json,$(MCP_TARGET_DIRS)) $(dir $(lastword $(MAKEFILE_LIST)))../.claude/settings.local.json

# NOTE: Do not sync `.codex/` wholesale. It's runtime state (auth, history, sessions) and
# can clobber Nix-managed `~/.codex/config.toml` during `make switch` (dotfiles repo).
DOTDIRS := .agent .agents .amazonq .augment .claude .cursor .gemini .idx .junie .kilocode .kiro .opencode .openhands .pi .qwen .roo .skillz .trae .vibe .vscode .windsurf .zed
DOTDIRS_SRC_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SKILLS_FILE := $(dir $(lastword $(MAKEFILE_LIST)))SKILLS.txt

# ====================================================================================
# ROOT TARGETS
# ====================================================================================

ifeq ($(DOTAGENTS_SKIP_SYNC),)
.PHONY: sync
sync: ruler-prepare ## Sync project commands, skills, and MCP configuration to assistant-specific directories.
	@$(MAKE) ruler-apply-global
	@$(MAKE) commands-sync
	@$(MAKE) skills-install
	@$(MAKE) skills-sync
	@$(MAKE) mcp-sync
	@$(MAKE) ruler-dotdirs-sync
endif

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

.PHONY: skills-clean
skills-clean: ## Remove all globally installed skills and cached install state.
	@for target in $(SKILLS_TARGET_DIRS); do \
		if [ -d "$$target" ]; then \
			rm -rf "$$target"/*; \
			echo "Cleaned $$target"; \
		fi; \
	done
	@if [ -d "$(SKILLS_STATE_DIR)" ]; then \
		rm -rf "$(SKILLS_STATE_DIR)"; \
		echo "Cleared $(SKILLS_STATE_DIR)"; \
	fi

.PHONY: skills-managed-clean
skills-managed-clean: ## Remove managed external skills recorded from SKILLS.txt.
	@manifest_dir="$(SKILLS_MANIFEST_DIR)"; \
	if [ -d "$$manifest_dir" ]; then \
		for manifest in "$$manifest_dir"/*.skills; do \
			if [ ! -f "$$manifest" ]; then \
				continue; \
			fi; \
			while IFS= read -r skill || [ -n "$$skill" ]; do \
				if [ -z "$$skill" ]; then \
					continue; \
				fi; \
				for target in $(SKILLS_TARGET_DIRS); do \
					if [ -e "$$target/$$skill" ] || [ -L "$$target/$$skill" ]; then \
						rm -rf "$$target/$$skill"; \
						echo "Removed $$target/$$skill"; \
					fi; \
				done; \
			done < "$$manifest"; \
		done; \
	fi
	@if [ -d "$(SKILLS_STATE_DIR)" ]; then \
		rm -rf "$(SKILLS_STATE_DIR)"; \
		echo "Cleared $(SKILLS_STATE_DIR)"; \
	fi

.PHONY: skills-install
skills-install: ## Ensure skills from SKILLS.txt are installed and reconcile managed removals.
	@state_dir="$(SKILLS_STATE_DIR)"; \
	manifest_dir="$(SKILLS_MANIFEST_DIR)"; \
	spec_state="$(SKILLS_SPEC_STATE_FILE)"; \
	external_source="$(SKILLS_EXTERNAL_SOURCE_DIR)"; \
	tmp_spec=$$(mktemp); \
	spec_changed=0; \
	failed=0; \
	mkdir -p "$$state_dir" "$$manifest_dir" "$$external_source"; \
	list_external_skills() { \
		if [ -d "$$external_source" ]; then \
			find "$$external_source" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -exec basename {} \; | LC_ALL=C sort -u; \
		fi; \
	}; \
	remove_repo_skills() { \
		manifest_file="$$1"; \
		if [ ! -f "$$manifest_file" ]; then \
			return 0; \
		fi; \
		while IFS= read -r skill || [ -n "$$skill" ]; do \
			if [ -z "$$skill" ]; then \
				continue; \
			fi; \
			for target in $(SKILLS_TARGET_DIRS); do \
				if [ -e "$$target/$$skill" ] || [ -L "$$target/$$skill" ]; then \
					rm -rf "$$target/$$skill"; \
				fi; \
			done; \
		done < "$$manifest_file"; \
	}; \
	list_repo_skills() { \
		repo="$$1"; \
		bunx skills add $$repo --global --yes --list </dev/null 2>&1 \
			| sed 's/\x1b\[[0-9;]*m//g' \
			| sed 's/\x1b\[?25[hl]//g' \
			| sed 's/\x1b\[999D\x1b\[J//g' \
			| grep -E '^│[[:space:]]{4}[a-z]' \
			| sed 's/^│[[:space:]]*//'; \
	}; \
	install_repo() { \
		repo="$$1"; \
		normalized_skills="$$2"; \
		manifest_file="$$3"; \
		cleanup_old="$$4"; \
		if [ "$$cleanup_old" = "1" ]; then \
			remove_repo_skills "$$manifest_file"; \
		fi; \
		if [ -n "$$normalized_skills" ]; then \
			skill_args=$$(printf '%s\n' "$$normalized_skills" | tr ',' '\n' | sed '/^$$/d' | while IFS= read -r s; do printf " --skill %s" "$$s"; done); \
			echo "Installing selected skills from $$repo..."; \
			if bunx skills add $$repo --global --yes $$skill_args </dev/null; then \
				printf '%s\n' "$$normalized_skills" | tr ',' '\n' | sed '/^$$/d' | LC_ALL=C sort > "$$manifest_file"; \
				echo "✓ Installed $$repo (selective)"; \
			else \
				echo "✗ Failed to install $$repo (continuing...)"; \
				failed=1; \
			fi; \
		else \
			echo "Installing all skills from $$repo..."; \
			if bunx skills add $$repo --global --yes </dev/null; then \
				list_repo_skills "$$repo" | LC_ALL=C sort > "$$manifest_file"; \
				echo "✓ Installed $$repo (all)"; \
			else \
				echo "✗ Failed to install $$repo (continuing...)"; \
				failed=1; \
			fi; \
		fi; \
	}; \
	while IFS= read -r raw_line || [ -n "$$raw_line" ]; do \
		line=$$(printf '%s' "$$raw_line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$$//'); \
		case "$$line" in \
			''|\#*) continue ;; \
		esac; \
		repo=$$(printf '%s\n' "$$line" | awk '{print $$1}'); \
		skills_csv=$$(printf '%s\n' "$$line" | awk '{print $$2}'); \
		normalized_skills=$$(printf '%s\n' "$$skills_csv" | tr ',' '\n' | sed '/^$$/d' | LC_ALL=C sort | paste -sd, -); \
		printf '%s|%s\n' "$$repo" "$$normalized_skills" >> "$$tmp_spec"; \
	done < "$(SKILLS_FILE)"; \
	if [ "$${DOTAGENTS_FORCE_SKILLS_INSTALL:-0}" = "1" ]; then \
		spec_changed=1; \
		echo "Forcing managed external skill reinstall..."; \
	elif [ ! -f "$$spec_state" ] || ! cmp -s "$$tmp_spec" "$$spec_state"; then \
		spec_changed=1; \
		echo "Detected SKILLS.txt changes; refreshing managed external skills..."; \
	fi; \
	if [ "$$spec_changed" = "1" ]; then \
		$(MAKE) skills-managed-clean; \
		mkdir -p "$$state_dir" "$$manifest_dir" "$$external_source"; \
		while IFS='|' read -r repo normalized_skills || [ -n "$$repo$$normalized_skills" ]; do \
			manifest_file="$$manifest_dir/$$(printf '%s' "$$repo" | sed 's#[^A-Za-z0-9_.-]#_#g').skills"; \
			install_repo "$$repo" "$$normalized_skills" "$$manifest_file" 0; \
		done < "$$tmp_spec"; \
	else \
		while IFS='|' read -r repo normalized_skills || [ -n "$$repo$$normalized_skills" ]; do \
			manifest_file="$$manifest_dir/$$(printf '%s' "$$repo" | sed 's#[^A-Za-z0-9_.-]#_#g').skills"; \
			reinstall_repo=0; \
			if [ ! -f "$$manifest_file" ] || [ ! -s "$$manifest_file" ]; then \
				reinstall_repo=1; \
				echo "Reinstalling $$repo (missing or empty manifest)"; \
			else \
				while IFS= read -r skill || [ -n "$$skill" ]; do \
					if [ -z "$$skill" ]; then \
						continue; \
					fi; \
					if [ ! -e "$$external_source/$$skill" ] && [ ! -L "$$external_source/$$skill" ]; then \
						reinstall_repo=1; \
						echo "Reinstalling $$repo (missing $$external_source/$$skill)"; \
						break; \
					fi; \
				done < "$$manifest_file"; \
			fi; \
			if [ "$$reinstall_repo" = "1" ]; then \
				install_repo "$$repo" "$$normalized_skills" "$$manifest_file" 1; \
			else \
				echo "Skipping $$repo (installed state matches SKILLS.txt)"; \
			fi; \
		done < "$$tmp_spec"; \
	fi; \
	cp "$$tmp_spec" "$$spec_state"; \
	rm -f "$$tmp_spec"; \
	if [ "$$failed" = "1" ]; then \
		echo "Some skills failed to install (see above)."; \
	else \
		echo "Managed external skills are in sync."; \
	fi

.PHONY: skills-refresh
skills-refresh: ## Force a clean reinstall of external skills and re-sync local repo skills.
	@$(MAKE) skills-managed-clean
	@DOTAGENTS_FORCE_SKILLS_INSTALL=1 $(MAKE) skills-install
	@$(MAKE) skills-sync

.PHONY: skills-install-repo
skills-install-repo: ## Install a single skill repo. Usage: make skills-install-repo REPO=owner/repo [SKILLS=a,b,c]
	@if [ -z "$(REPO)" ]; then \
		echo "Error: REPO is required. Usage: make skills-install-repo REPO=owner/repo"; \
		exit 1; \
	fi
	@if [ -n "$(SKILLS)" ]; then \
		echo "Installing selected skills from $(REPO) ($(SKILLS))..."; \
		bunx skills add $(REPO) --global --yes $(shell echo "$(SKILLS)" | tr ',' '\n' | sed '/^$$/d' | while read -r s; do printf " --skill $$s"; done); \
	else \
		echo "Installing all skills from $(REPO)..."; \
		bunx skills add $(REPO) --global --yes; \
	fi
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
	@keys=$$(jq -c '.mcpServers | keys' $(MCP_SRC)); \
	for settings in $(MCP_SETTINGS_TARGETS); do \
		if [ -f "$$settings" ]; then \
			jq --argjson keys "$$keys" '.enabledMcpjsonServers = $$keys' "$$settings" > "$$settings.tmp" && \
			mv "$$settings.tmp" "$$settings"; \
			echo "Updated enabledMcpjsonServers in $$settings"; \
		fi; \
	done

# ====================================================================================
# RULER GLOBAL
# ====================================================================================

.PHONY: ruler-apply-global
ruler-apply-global: ruler-prepare ## Apply Ruler outputs to global paths.
	@bash -c 'set -e; \
		ruler_src="$(abspath $(dir $(lastword $(MAKEFILE_LIST))))/.ruler"; \
		ruler_home="$$HOME/.ruler"; \
		rsync -a --delete "$$ruler_src/" "$$ruler_home/"; \
		bunx @intellectronica/ruler apply --project-root "$$HOME" --config "$$ruler_home/ruler.toml" --local-only'

.PHONY: ruler-dotdirs-sync
ruler-dotdirs-sync: ## Sync repo dot directories to $HOME equivalents.
	@bash -c 'set -e; \
		root="$(DOTDIRS_SRC_DIR)"; \
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
