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
    rustc
    cargo

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
    # golang
    go
    # golang lsp
    gopls
    # staticcheck for golang
    go-tools
    # golang linter
    golangci-lint
    delve
    # reverse proxy tools
    frp
    # yaml lint and processor
    yq-go

    # replace of df
    duf
    # replace of du
    gdu
    # replace of find
    fd
    # rg
    ripgrep

    # useful leetcode cli
    leetgo
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
