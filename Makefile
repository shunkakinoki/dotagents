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
SKILLS_FILE := $(dir $(lastword $(MAKEFILE_LIST)))SKILLS.txt
SKILLS_LOCK_FILE := $(dir $(lastword $(MAKEFILE_LIST)))skills-lock.json
SKILLS_EXTERNAL_SOURCE_DIR := $(HOME)/.agents/skills
SKILLS_GLOBAL_LOCK := $(HOME)/.agents/.skill-lock.json
SKILLS_CLI := ./node_modules/.bin/skills

MCP_SRC := $(dir $(lastword $(MAKEFILE_LIST))).ruler/mcp.json
MCP_TARGET_DIRS := $(HOME)/.cursor $(HOME)/.claude $(HOME)/.codex
MCP_SETTINGS_TARGETS := $(addsuffix /settings.local.json,$(MCP_TARGET_DIRS)) $(dir $(lastword $(MAKEFILE_LIST)))../.claude/settings.local.json

# NOTE: Do not sync `.codex/` wholesale. It's runtime state (auth, history, sessions) and
# can clobber Nix-managed `~/.codex/config.toml` during `make switch` (dotfiles repo).
DOTDIRS := .agent .agents .amazonq .augment .claude .cursor .gemini .idx .junie .kilocode .kiro .opencode .openhands .pi .qwen .roo .skillz .trae .vibe .vscode .windsurf .zed
DOTDIRS_SRC_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

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
# External skills are declared in SKILLS.txt and locked in skills-lock.json.

.PHONY: skills-install
skills-install: ## Install external skills from skills-lock.json (skips already installed; does not rewrite the lock).
	@lock="$(SKILLS_LOCK_FILE)"; \
	skills_dir="$(SKILLS_EXTERNAL_SOURCE_DIR)"; \
	force="$${DOTAGENTS_FORCE_SKILLS_INSTALL:-0}"; \
	if ! bun install --frozen-lockfile --minimum-release-age 0 --no-progress >/dev/null; then \
		echo "Error: failed to install the skills SDK from bun.lock"; \
		exit 1; \
	fi; \
	if [ ! -f "$$lock" ]; then \
		echo "Error: $$lock not found"; \
		exit 1; \
	fi; \
	tmp_missing=$$(mktemp); \
	jq -r '.skills | to_entries[] | [(.value.sourceUrl // .value.source) + (if .value.ref then "#" + .value.ref else "" end), .key] | @tsv' "$$lock" \
	| while read -r source name; do \
		if [ "$$force" = "1" ] || { [ ! -e "$$skills_dir/$$name" ] && [ ! -L "$$skills_dir/$$name" ]; }; then \
			printf '%s\t%s\n' "$$source" "$$name"; \
		fi; \
	done | LC_ALL=C sort > "$$tmp_missing"; \
	if [ ! -s "$$tmp_missing" ]; then \
		rm -f "$$tmp_missing"; \
		echo "All skills from skills-lock.json are installed."; \
		exit 0; \
	fi; \
	failed=0; \
	for source in $$(cut -f1 "$$tmp_missing" | uniq); do \
		names=$$(awk -F'\t' -v s="$$source" '$$1 == s {print $$2}' "$$tmp_missing"); \
		skill_args=$$(printf '%s\n' "$$names" | while IFS= read -r n; do printf ' --skill %s' "$$n"; done); \
		count=$$(printf '%s\n' "$$names" | wc -l | tr -d ' '); \
		echo "Installing $$count skill(s) from $$source..."; \
		$(SKILLS_CLI) add "$$source" --global --yes $$skill_args </dev/null; \
		status=$$?; \
		still_missing=$$(printf '%s\n' "$$names" | while IFS= read -r n; do \
			if [ ! -e "$$skills_dir/$$n" ] && [ ! -L "$$skills_dir/$$n" ]; then printf ' %s' "$$n"; fi; \
		done); \
		if [ -n "$$still_missing" ] || { [ "$$force" = "1" ] && [ "$$status" != "0" ]; }; then \
			echo "Failed to install from $$source:$$still_missing"; \
			failed=1; \
		fi; \
	done; \
	rm -f "$$tmp_missing"; \
	if [ "$$failed" = "0" ] && [ -f "$(SKILLS_GLOBAL_LOCK)" ]; then \
		$(MAKE) skills-lock || failed=1; \
	fi; \
	exit $$failed

.PHONY: skills-refresh
skills-refresh: ## Force a reinstall of all external skills from skills-lock.json.
	@DOTAGENTS_FORCE_SKILLS_INSTALL=1 $(MAKE) skills-install

.PHONY: skills-update
skills-update: ## Update installed external skills to latest and refresh the lock.
	@bun install --frozen-lockfile --minimum-release-age 0 --no-progress >/dev/null
	@$(SKILLS_CLI) update --global --yes </dev/null
	@$(MAKE) skills-lock

.PHONY: skills-lock
skills-lock: ## Regenerate skills-lock.json from SKILLS.txt.
	@global_lock="$(SKILLS_GLOBAL_LOCK)"; \
	skills_dir="$(SKILLS_EXTERNAL_SOURCE_DIR)"; \
	if [ ! -f "$$global_lock" ]; then \
		echo "Error: $$global_lock not found; install a skill first ($(SKILLS_CLI) add ... --global) to initialize it."; \
		exit 1; \
	fi; \
	if ! jq -e '(.version | type == "number") and (.skills | type == "object")' "$$global_lock" >/dev/null; then \
		echo "Error: $$global_lock is missing version/skills fields"; \
		exit 1; \
	fi; \
	ondisk=$$(find "$$skills_dir" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -exec basename {} \; 2>/dev/null | jq -R . | jq -s .); \
	spec=$$(awk '!/^[[:space:]]*(#|$$)/ {print $$1 "\t" $$2}' "$(SKILLS_FILE)" | jq -R -s 'split("\n") | map(select(length > 0) | split("\t") | {repo: .[0], names: (if (.[1] // "") == "" then [] else (.[1] | split(",") | map(select(length > 0))) end)})'); \
	jq --argjson ondisk "$$ondisk" --argjson spec "$$spec" '. as $$lock | ($$lock.skills | with_entries(select(.key as $$k | $$ondisk | index($$k))) | with_entries(.value |= ({source, sourceType, sourceUrl, ref, skillPath, skillFolderHash} | with_entries(select(.value != null))))) as $$inst | reduce $$spec[] as $$s ({}; if ($$s.names | length) == 0 then . + ($$inst | with_entries(select(.value.source | ascii_downcase == ($$s.repo | ascii_downcase)))) else reduce $$s.names[] as $$n (.; ($$inst[$$n] // null) as $$hit | .[$$n] = (if $$hit != null and (($$hit.source | ascii_downcase) == ($$s.repo | ascii_downcase)) then $$hit elif .[$$n] != null then .[$$n] elif ($$s.repo | test("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$$")) then {source: $$s.repo, sourceType: "github", sourceUrl: "https://github.com/\($$s.repo).git"} else {source: $$s.repo} end)) end) | {version: $$lock.version, skills: (to_entries | sort_by(.key) | from_entries)}' "$$global_lock" > "$(SKILLS_LOCK_FILE).tmp" && mv "$(SKILLS_LOCK_FILE).tmp" "$(SKILLS_LOCK_FILE)"; \
	for repo in $$(printf '%s' "$$spec" | jq -r '.[] | select(.names | length == 0) | .repo'); do \
		if ! jq -e --arg repo "$$repo" '[.skills[] | select(.source | ascii_downcase == ($$repo | ascii_downcase))] | length > 0' "$(SKILLS_LOCK_FILE)" >/dev/null; then \
			echo "warn: no installed skills for install-all repo $$repo; run: bun install --frozen-lockfile --minimum-release-age 0 && $(SKILLS_CLI) add $$repo --global --yes --skill '*'"; \
		fi; \
	done; \
	undeclared=$$(jq -r --argjson ondisk "$$ondisk" --slurpfile out "$(SKILLS_LOCK_FILE)" '.skills | keys[] | . as $$k | select(($$ondisk | index($$k)) and ($$out[0].skills | has($$k) | not))' "$$global_lock" | paste -sd, -); \
	if [ -n "$$undeclared" ]; then \
		echo "warn: installed but not declared in SKILLS.txt: $$undeclared"; \
	fi; \
	jq -r --argjson ondisk "$$ondisk" '.skills | "skills-lock.json: \(length) skills (\([keys[] | select(. as $$k | $$ondisk | index($$k) | not)] | length) not yet installed)"' "$(SKILLS_LOCK_FILE)"

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
		bun x @intellectronica/ruler apply --project-root "$$HOME" --config "$$ruler_home/ruler.toml" --local-only'

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
