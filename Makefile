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

.PHONY: build build-nixos build-darwin

.PHONY: darwin-set-proxy
darwin-set-proxy:
	@sudo python3 hack/darwin-set-proxy.py -s http://127.0.0.1:7890

.PHONY: check-store
check-store:
	sudo nix-store --repair --verify --check-contents

.PHONY: fmt
fmt:
	@ echo -e "\033[32mbegin to format nixos-config repos\033[0m"
	@ treefmt
	@ nu ./scripts/git-tree-dirty-check.nu

.PHONY: waybar-restart
waybar-restart:
	@ killall -SIGUSR2 .waybar-wrapped

.PHONY: gc
gc:
	@ sudo nix-store --gc
	@ nix-collect-garbage -d
