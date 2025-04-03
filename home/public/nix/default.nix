{pkgs, ...}: {
  home.packages = with pkgs; [
    statix
    nixd
    node2nix
  ];
}
