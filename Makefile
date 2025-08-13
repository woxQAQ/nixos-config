HOST = "woxQAQ"
UNAME = $(shell uname)

.PHONY: bump-flake
bump-flake: fmt
	nix flake update --flake . --extra-experimental-features "nix-command flakes"

.PHONY: replw
repl:
	nix repl --extra-experimental-features "nix-command flakes"

.PHONY: shell
shell:
	nix shell --extra-experimental-features "nix-command flakes"

.PHONY: switch
switch: fmt
	sudo nixos-rebuild switch --flake ".#${HOST}"

.PHONY: switch-wsl
switch-wsl:
	sudo nixos-rebuild switch \
		--flake .#wsl

.PHONY: switch
switch-nas: fmt
		sudo nixos-rebuild switch \
		--flake .#woxQAQ \

check-brew:
	@if command -v brew &>/dev/null; then \
		echo "Homebrew installed"; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		exit 1; \
	fi

.PHONY: switch-darwin
switch-darwin: fmt
	@sudo darwin-rebuild switch \
  --flake .#woxMac \

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

.PHONY: waybar-restart
waybar-restart:
	@ killall -SIGUSR2 .waybar-wrapped

.PHONY: gc
gc:
	@ sudo nix-store --gc
