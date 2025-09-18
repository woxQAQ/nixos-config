{
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./claude-code.nix
  ];
  home.packages = with pkgs; [
    # nodejs
    # nodePackages.npm
    pnpm
    yarn
    nodejs_20
    bun

    clang
    clang-tools

    rustfmt
    rustc
    cargo
    rust-analyzer

    python3
    uv
    black
    ruff

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
    nodePackages.jsonlint
    checkmake

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
    # llm cli
    aichat
  ];
  # home.file.".npmrc".text = ''
  #   prefix=~/.npm-packages
  # '';
  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.npm/bin"
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
}
