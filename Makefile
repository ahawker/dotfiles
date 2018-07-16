.DEFAULT_GOAL := help

LOGGERFILE ?= .logger
ifneq ($(strip $(wildcard $(LOGGERFILE))),)
	include $(LOGGERFILE)
endif

INTERACTIVE_SHELL := $(shell [ -t 0 ] && echo 1 || echo 0)

STOW_DIR := dotfiles
STOW_TARGET := $(HOME)
STOW_PACKAGES := *
ifdef IGNORE_SHELL_RC_FILES
	STOW_PACKAGES := $(shell ls $(STOW_DIR) | grep -vE "(bash|zsh)")
endif

SHELLCHECK_REPO := ahawker
SHELLCHECK_IMAGE := $(SHELLCHECK_REPO)/shellcheck
SHELLCHECK_VOLUME := $(shell pwd)
SHELLCHECK_WORKDIR := /app
SHELLCHECK_OPTS := -e SC1090

SHELLCHECK_DOCKER_FLAGS := --interactive --rm
ifeq ($(INTERACTIVE_SHELL), 1)
	SHELLCHECK_DOCKER_FLAGS += --tty
endif

.PHONY: install
install: stow | requirements  ## Install all dotfile packages.
	$(call TRACE, Running '$@' for all packages)
	@(cd $(STOW_DIR) && exec stow -t $(STOW_TARGET) -S $(STOW_PACKAGES))
	$(call TRACE, Completed '$@' for all packages)

.PHONY: install-%
install-%: stow | requirements  ## Install individual dotfile package by name, e.g. 'install-bash'.
	$(call TRACE, Running 'install' for '$*' package)
	@(cd $(STOW_DIR) && exec stow -t $(STOW_TARGET) -R $*)
	$(call TRACE, Completed 'install' for '$*' package)

.PHONY: reinstall
reinstall: stow | requirements  ## Reinstall all dotfile packages.
	$(call TRACE, Running '$@' for all packages)
	@(cd $(STOW_DIR) && exec stow -t $(STOW_TARGET) -R $(STOW_PACKAGES))
	$(call TRACE, Completed '$@' for all packages)

.PHONY: reinstall-%
reinstall-%: stow | requirements  ## Reinstall individual dotfile package by name, e.g. 'reinstall-bash'.
	$(call TRACE, Running 'reinstall' for '$*' package)
	@(cd $(STOW_DIR) && exec stow -t $(STOW_TARGET) -R $*)
	$(call TRACE, Completed 'reinstall' for '$*' package)

.PHONY: uninstall
uninstall: stow | requirements  ## Uninstall all dotfiles packages.
	$(call TRACE, Running '$@' for all packages)
	@(cd $(STOW_DIR) && exec stow -t $(STOW_TARGET) -D $(STOW_PACKAGES))
	$(call TRACE, Completed '$@' for all packages)

.PHONY: uninstall-%
uninstall-%: stow | requirements  ## Uninstall individual dotfile package by name, e.g. 'reinstall-bash'.
	$(call TRACE, Running 'uninstall' for '$*' package)
	@(cd $(STOW_DIR) && exec stow -t $(STOW_TARGET) -D $*)
	$(call TRACE, Completed 'uninstall' for '$*' package)

.PHONY: test
test: stow reinstall | test-requirements  ## Run 'shellcheck' tests against dotfile packages.
	$(call TRACE, Running '$@' for all packages)
	@docker run $(SHELLCHECK_DOCKER_FLAGS) \
		--volume $(SHELLCHECK_VOLUME):$(SHELLCHECK_WORKDIR) \
		--workdir $(SHELLCHECK_WORKDIR) \
		$(SHELLCHECK_IMAGE) \
		/usr/bin/env sh -c 'find $(STOW_DIR) -type f ! -path "*.git*" | xargs -I % file % | grep script | cut -d " " -f 1 | sed "s/.$$//" | xargs shellcheck $(SHELLCHECK_OPTS)'
	$(call TRACE, Completed '$@' for all packages)

.PHONY: stow
stow: | requirements
	@(cd $(STOW_DIR) && exec stow -t $(STOW_TARGET) -R stow)

.PHONY: requirements
requirements: requires-command-stow \
	requires-STOW_DIR \
	requires-STOW_TARGET \
	requires-STOW_PACKAGES

.PHONY: test-requirements
test-requirements: requires-command-docker \
	requires-SHELLCHECK_REPO \
	requires-SHELLCHECK_IMAGE \
	requires-SHELLCHECK_VOLUME \
	requires-SHELLCHECK_WORKDIR \
	requires-SHELLCHECK_DOCKER_FLAGS

.PHONY: requires-command-%
requires-command-%:
	@if [ ! $$(command -v $* 2> /dev/null) ] ; then echo 'Required command "$*" not found' && exit 1; fi

.PHONY: requires-%
requires-%:
	@if [ -z '${${*}}' ]; then echo 'Required variable "$*" not set' && exit 1; fi

.PHONY: help
help: ## Print Makefile usage.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
