{
  pkgs,
  unstable-pkg,
  ...
}: {
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
    clang
    dbeaver-bin

    treefmt2
    unstable-pkg.rustc
    unstable-pkg.rust-analyzer
    unstable-pkg.cargo
    unstable-pkg.rustfmt
    unstable-pkg.clippy

    zulu23

    go
  ];
}
