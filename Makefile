.DEFAULT_GOAL := help

LOGGERFILE ?= .logger
ifneq ($(strip $(wildcard $(LOGGERFILE))),)
	include $(LOGGERFILE)
endif

STOW_DIR := dotfiles
STOW_PATH := $(shell command -v stow 2> /dev/null)
STOW_TARGET := $(HOME)

SHELLCHECK_PATH := $(shell command -v shellcheck 2> /dev/null)

.PHONY: install
install: stow | requirements  ## Install all dotfile packages.
	$(call TRACE, Running '$@' for all packages)
	@(cd $(STOW_DIR) && stow -t $(STOW_TARGET) -S *)
	$(call TRACE, Completed '$@' for all packages)

.PHONY: install-%
install-%: stow | requirements  ## Install individual dotfile package by name, e.g. 'install-bash'.
	$(call TRACE, Running 'install' for '$*' package)
	@(cd $(STOW_DIR) && stow -t $(STOW_TARGET) -R $*)
	$(call TRACE, Completed 'install' for '$*' package)

.PHONY: reinstall
reinstall: stow | requirements  ## Reinstall all dotfile packages.
	$(call TRACE, Running '$@' for all packages)
	@(cd $(STOW_DIR) && stow -t $(STOW_TARGET) -R *)
	$(call TRACE, Completed '$@' for all packages)

.PHONY: reinstall-%
reinstall-%: stow | requirements  ## Reinstall individual dotfile package by name, e.g. 'reinstall-bash'.
	$(call TRACE, Running 'reinstall' for '$*' package)
	@(cd $(STOW_DIR) && stow -t $(STOW_TARGET) -R $*)
	$(call TRACE, Completed 'reinstall' for '$*' package)

.PHONY: uninstall
uninstall: stow | requirements  ## Uninstall all dotfiles packages.
	$(call TRACE, Running '$@' for all packages)
	@(cd $(STOW_DIR) && stow -t $(STOW_TARGET) -D *)
	$(call TRACE, Completed '$@' for all packages)

.PHONY: uninstall-%
uninstall-%: stow | requirements  ## Uninstall individual dotfile package by name, e.g. 'reinstall-bash'.
	$(call TRACE, Running 'uninstall' for '$*' package)
	@(cd $(STOW_DIR) && stow -t $(STOW_TARGET) -D $*)
	$(call TRACE, Completed 'uninstall' for '$*' package)

.PHONY: test
test: stow reinstall | test-requirements  ## Run 'shellcheck' tests against dotfile packages.
	$(call TRACE, Running '$@' for all packages)
	@find $(STOW_DIR) -type f ! -path '*.git*' | xargs -I % file % | grep script | cut -d ' ' -f 1 | sed 's/.$$//' | xargs shellcheck
	$(call TRACE, Completed '$@' for all packages)

.PHONY: stow
stow: | requirements
	@(cd $(STOW_DIR) && stow -t $(STOW_TARGET) -R stow)

.PHONY: requirements
requirements: requires-STOW_PATH requires-STOW_DIR requires-STOW_TARGET

.PHONY: test-requirements
test-requirements: requires-SHELLCHECK_PATH

.PHONY: requires-%
requires-%:
	@if [ -z '${${*}}' ]; then echo 'Required variable "$*" not set' && exit 1; fi

.PHONY: help
help: ## Print Makefile usage.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
