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

    clang
    clang-tools

    rustfmt

    python3
    uv
    black

    gdb
    deadnix
    dbeaver-bin

    graphviz

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
  # home.file.".npmrc".text = ''
  #   prefix=~/.npm-packages
  # '';
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
