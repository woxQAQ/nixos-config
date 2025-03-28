HOST = "woxQAQ"
UNAME = $(shell uname)

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

deploy-darwin:
	nix build .#darwinConfigurations.woxMac.system \
	   --extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#hostname

.PHONY: fmt
fmt:
	treefmt

.PHONY: waybar-restart
waybar-restart:
	@ killall -SIGUSR2 .waybar-wrapped
