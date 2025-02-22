{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
    nodePackages.npm
    yarn
    nodePackages.pnpm

    python3
    uv

    gdb
    gcc

    treefmt2
    cargo

    zulu23

    go
  ];
}
