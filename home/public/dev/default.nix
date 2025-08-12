{
  pkgs,
  unstable-pkg,
  ...
}:
{
  imports = [
    ./git.nix
  ];
  home.packages = with pkgs; [
    # nodejs
    # nodePackages.npm
    pnpm
    yarn
    nodejs_20

    python3
    pyenv
    uv

    gdb
    lldb
    deadnix
    clang
    dbeaver-bin

    graphviz
    unstable-pkg.rustc
    unstable-pkg.rust-analyzer
    unstable-pkg.cargo
    unstable-pkg.rustfmt
    unstable-pkg.clippy

    zulu23
    maven
    protobuf
    protols
    unstable-pkg.go
    unstable-pkg.gopls
    unstable-pkg.go-tools
    unstable-pkg.golangci-lint
    unstable-pkg.delve
    frp
    yq-go
    duf
    gdu
  ];
  home.file.".npmrc".text = ''
    prefix=~/.npm-packages
  '';
  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.npm-packages/bin"
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
}
