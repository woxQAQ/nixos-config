HOST = "wox-pc"
UNAME = $(shell uname)

.PHONY: test
test:
	nix-rebuild test --flake ".#${HOST}"

.PHONY: switch
switch:
	nix-rebuild switch --flake ".#${HOST}"

.PHONY: fmt
fmt:
	treefmt

.PHONY: statix
statix:
    statix check >> out
