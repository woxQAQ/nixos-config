{ pkgs, ... }:
{
  home.packages = with pkgs; [
    statix
    nixd
    hydra-check
    nix-tree
    nix-index
  ];
}
