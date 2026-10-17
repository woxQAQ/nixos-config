NIXOS_HOST ?= woxQAQ
DARWIN_HOST = woxMac
WOXVIM_FLAKE_INPUT = woxVim
SECRET_FLAKE_INPUT = secrets
OS = $(shell uname)
_SWITCH_FLAGS ?=
OPTIONS ?=

TRACE ?= 0
.DEFAULT_GOAL := switch

ifeq ($(OS),Darwin)
NIX_FLAG = --extra-experimental-features "nix-command flakes"
NIX = nix $(NIX_FLAG)
else
NIX = nix
endif

ifeq ($(TRACE),1)
_SWITCH_FLAGS += --show-trace
endif

.PHONY: bump-flake bump-dev bump-secrets bump-woxVim repl shell
bump:
	@if command -v nu &>/dev/null; then \
		nu ./update-flake-inputs.nu; \
	else \
		echo "nushell not installed"; \
		exit 1;\
	fi
bump-flake:
	just bump-flake

bump-dev:
	just bump-dev

bump-secrets:
	just bump-flake "$(SECRET_FLAKE_INPUT)"

bump-woxVim:
	just bump-flake "$(WOXVIM_FLAKE_INPUT)"
	@ if [ $(OS) = "Darwin" ]; then \
		$(MAKE) switch-darwin; \
	else \
		$(MAKE) switch; \
	fi

repl:
	$(NIX) repl

shell:
	just shell

.PHONY: switch switch-wsl switch-darwin
switch: fmt
	nixos-rebuild switch --sudo --flake ".#${NIXOS_HOST}" \
		$(_SWITCH_FLAGS) $(OPTIONS)

switch-wsl: fmt
	nixos-rebuild switch --sudo --flake .#wsl $(_SWITCH_FLAGS)

check-brew:
	@if command -v brew &>/dev/null; then \
		echo "Homebrew installed"; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		exit 1; \
	fi

switch-darwin: fmt
	@sudo darwin-rebuild switch --flake ".#${DARWIN_HOST}" $(_SWITCH_FLAGS)

.PHONY: check check-hosts
check:
	just check

check-hosts:
	just check-hosts

.PHONY: check-store
check-store:
	sudo nix-store --repair --verify --check-contents

.PHONY: fmt
fmt:
	$(NIX) fmt

.PHONY: gc
gc:
	sudo nix-collect-garbage --delete-older-than 7d
	nix-collect-garbage --delete-older-than 7d
