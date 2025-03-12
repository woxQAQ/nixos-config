{pkgs, ...}: {
  home.packages = with pkgs; [
    nodejs
    nodePackages.npm
    nodePackages.prettier
    yarn
    nodePackages.pnpm

    python3
    pyenv
    uv

    gdb
    gcc

    treefmt2
    cargo
    rustc

    zulu23

    go
  ];
}
