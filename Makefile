NIXOS_HOST ?= woxQAQ
DARWIN_HOST = "woxMac"
WOXVIM_FLAKE_INPUT = "woxVim"
OS = $(shell uname)
_SWITCH_FLAGS ?=
SUBSTITUTERS = https://mirror.sjtu.edu.cn/nix-channels/store
_USE_SUBSTITUTERS = 0
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

ifeq ($(_USE_SUBSTITUTERS),1)
OPTIONS += --option $(SUBSTITUTERS)
endif


.PHONY: bump-flake repl shell
bump-flake: fmt
	$(NIX) flake update --flake .

bump-woxVim: fmt
	$(NIX) flake update ${WOXVIM_FLAKE_INPUT}
	@ if [ $(OS) = "Darwin" ]; then \
		$(MAKE) switch-darwin; \
	else \
		$(MAKE) switch; \
	fi

repl:
	$(NIX) repl

shell:
	$(NIX) shell

.PHONY: switch switch-wsl switch-darwin
switch: fmt
	sudo nixos-rebuild switch --flake ".#${NIXOS_HOST}" \
		$(_SWITCH_FLAGS) $(OPTIONS)

switch-wsl: fmt
	sudo nixos-rebuild switch --flake .#wsl $(_SWITCH_FLAGS)

check-brew:
	@if command -v brew &>/dev/null; then \
		echo "Homebrew installed"; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		exit 1; \
	fi

switch-darwin: fmt
	@sudo darwin-rebuild switch --flake ".#${DARWIN_HOST}" $(_SWITCH_FLAGS)

.PHONY: check check-darwin check-linux
check: fmt
	$(NIX) flake check --keep-going

.PHONY: darwin-set-proxy
darwin-set-proxy:
	@sudo python3 hack/darwin-set-proxy.py -s http://127.0.0.1:7897

.PHONY: check-store
check-store:
	sudo nix-store --repair --verify --check-contents

.PHONY: fmt
fmt:
	$(NIX) fmt

.PHONY: waybar-restart
waybar-restart:
	@ killall -SIGUSR2 .waybar-wrapped

.PHONY: gc
gc:
	sudo nix-collect-garbage --delete-older-than 7d
	nix-collect-garbage --delete-older-than 7d
