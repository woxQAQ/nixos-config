{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    zip
    unzip
    p7zip
    gamescope
    repgrep
    yq-go
    jq
    htop
    putty
    go
    node2nix
    dbeaver-bin
    dbgate
    mpv
    neofetch
    font-manager
    zulu23
    tldr
    qq
    ripgrep
    treefmt2
    wl-clipboard
    gcc
    gdb
    duf
    gdu
    obs-studio
    python3
    nixd
    graphviz
    xdg-utils
    wineWowPackages.wayland
    nodejs
    nodePackages.npm
    yarn
    nodePackages.pnpm
  ];
  home.file.".npmrc".text = ''
    prefix=~/.npm-packages
  '';
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
    jq.enable = true;
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };
    go = {
      enable = true;
      goPath = "go";
    };
  };
  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.npm-packages/bin"
  ];
}
