HOST = "wox-pc"
UNAME = $(shell uname)

.PHONY: test
test:
	nix-rebuild test --flake ".#${HOST}"

.PHONY: switch
switch:
	nix-rebuild switch --flake ".#${HOST}"

.PHONY: switch-wsl
switch-wsl:
	sudo nix-rebuild switch --flake .#wsl

.PHONY: fmt
fmt:
	treefmt

.PHONY: waybar-restart
waybar-restart:
	@ killall -SIGUSR2 .waybar-wrapped
