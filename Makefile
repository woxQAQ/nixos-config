NIXOS_HOST = "woxQAQ"
DARWIN_HOST = "woxMac"
WOXVIM_FLAKE_INPUT = "woxVim"
OS = $(shell uname)

ifeq ($(OS),Darwin)
	NIX_FLAG = --extra-experimental-features "nix-command flakes"
	NIX = nix $(NIX_FLAG)
else
	NIX = nix
endif

.PHONY: bump-flake repl shell
bump-flake: fmt
	$(NIX) flake update --flake .

bump-woxVim: fmt
	$(NIX) flake lock --update-input ${WOXVIM_FLAKE_INPUT}
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
	sudo nixos-rebuild switch --flake ".#${NIXOS_HOST}"

switch-wsl: fmt
	sudo nixos-rebuild switch --flake .#wsl

check-brew:
	@if command -v brew &>/dev/null; then \
		echo "Homebrew installed"; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		exit 1; \
	fi

switch-darwin: fmt
	@sudo darwin-rebuild switch --flake ".#${DARWIN_HOST}"

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
