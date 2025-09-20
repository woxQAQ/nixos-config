{ pkgs, ... }:
{
  home.packages = with pkgs; [
    statix
    nixd
    # nom
    # nix-output-monitor
    # generate nix derivation from url
    nix-init
    hydra-check
    # tui to visualize the dependency graph of a nix derivation
    nix-tree
    # index nix store paths
    nix-index
    # tui for flake.lock
    nix-melt
  ];
}
