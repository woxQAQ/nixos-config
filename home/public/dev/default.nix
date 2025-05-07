{
  pkgs,
  unstable-pkg,
  ...
}: {
  imports = [
    ./git.nix
  ];
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

    lazydocker
    graphviz
    unstable-pkg.rustc
    unstable-pkg.rust-analyzer
    unstable-pkg.cargo
    unstable-pkg.rustfmt
    unstable-pkg.clippy

    zulu23

    protols
    unstable-pkg.go
    unstable-pkg.gopls
    unstable-pkg.go-tools
    unstable-pkg.golangci-lint
    repgrep
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
  programs = {
    fzf = {
      enable = true;
      colors = {
        "bg+" = "#313244";
        "bg" = "#1e1e2e";
        "spinner" = "#f5e0dc";
        "hl" = "#f38ba8";
        "fg" = "#cdd6f4";
        "header" = "#f38ba8";
        "info" = "#cba6f7";
        "pointer" = "#f5e0dc";
        "marker" = "#f5e0dc";
        "fg+" = "#cdd6f4";
        "prompt" = "#cba6f7";
        "hl+" = "#f38ba8";
      };
    };
    tmux = {
      enable = true;
    };
    bat = {
      enable = true;
      # config = {
      #   paper = "less -FR";
      # };
    };
    btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin_mocha";
        theme_background = false; # make btop transparent
      };
    };
    jq.enable = true;
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };
    # go = {
    #   enable = true;
    #   goPath = "go";
    # };
  };
}
