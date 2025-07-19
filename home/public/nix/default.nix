{ pkgs, ... }:
{
  home.packages = with pkgs; [
    statix
    nixd
    hydra-check
    nix-index
    nix-tree
  ];
}
