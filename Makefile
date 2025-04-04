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

.PHONY: switch-nas
switch-nas:
		sudo nixos-rebuild switch \
		--flake .#nas \
		--option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

.PHONY: switch-darwin
switch-darwin:
	sudo darwin-rebuild switch \
  --flake .#woxMac --show-trace \
  --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

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
