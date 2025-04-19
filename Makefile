HOST = "woxQAQ"
UNAME = $(shell uname)

.PHONY: update-flake
update-flake:
	nix flake update --flake . --extra-experimental-features "nix-command flakes"

.PHONY: repl
repl:
	nix repl --extra-experimental-features "nix-command flakes"

.PHONY: shell
shell:
	nix shell --extra-experimental-features "nix-command flakes"

.PHONY: switch
switch:
	sudo nixos-rebuild switch --flake ".#${HOST}"

.PHONY: switch-wsl
switch-wsl:
	sudo nixos-rebuild switch --flake .#wsl

.PHONY: switch-nas
switch-nas:
		sudo nixos-rebuild switch \
		--flake .#nas \
		--option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
check-brew:
	@if command -v brew &>/dev/null; then \
		echo "Homebrew installed"; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		exit 1; \
	fi

.PHONY: switch-darwin
switch-darwin: check-brew
	darwin-rebuild switch \
  --flake .#woxMac --show-trace \

.PHONY: check-store
	sudo nix-store --repair --verify --check-contents

.PHONY: deploy-darwin
deploy-darwin:
	nix build .#darwinConfigurations.woxMac.system \
	   --extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#woxMac

.PHONY: fmt
fmt:
	treefmt

.PHONY: waybar-restart
waybar-restart:
	@ killall -SIGUSR2 .waybar-wrapped
