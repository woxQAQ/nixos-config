HOST = "woxQAQ"
UNAME = $(shell uname)

.PHONY: bump-flake repl shell
bump-flake: fmt
	nix flake update --flake . --extra-experimental-features "nix-command flakes"

repl:
	nix repl --extra-experimental-features "nix-command flakes"

shell:
	nix shell --extra-experimental-features "nix-command flakes"

.PHONY: switch switch-wsl switch-darwin
switch: fmt
	sudo nixos-rebuild switch --flake ".#${HOST}"

switch-wsl: fmt
	sudo nixos-rebuild switch \
		--flake .#wsl

check-brew:
	@if command -v brew &>/dev/null; then \
		echo "Homebrew installed"; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		exit 1; \
	fi

switch-darwin: fmt
	@sudo darwin-rebuild switch \
  --flake .#woxMac


.PHONY: check check-darwin check-linux
check: fmt
	nix flake check --extra-experimental-features "nix-command flakes" --keep-going



.PHONY: darwin-set-proxy
darwin-set-proxy:
	@sudo python3 hack/darwin-set-proxy.py -s http://127.0.0.1:7897

.PHONY: check-store
check-store:
	sudo nix-store --repair --verify --check-contents

.PHONY: fmt
fmt:
	nix fmt --extra-experimental-features "nix-command flakes"

.PHONY: waybar-restart
waybar-restart:
	@ killall -SIGUSR2 .waybar-wrapped

.PHONY: gc
gc:
	sudo nix-collect-garbage --delete-older-than 7d
	nix-collect-garbage --delete-older-than 7d
