HOST = "woxQAQ"
UNAME = $(shell uname)

.PHONY: repl
repl:
	nix repl

.PHONY: switch
switch:
	sudo nixos-rebuild switch --flake ".#${HOST}"

.PHONY: switch-wsl
switch-wsl:
	sudo nixos-rebuild switch --flake .#wsl

.PHONY: fmt
fmt:
	treefmt

.PHONY: waybar-restart
waybar-restart:
	@ killall -SIGUSR2 .waybar-wrapped
