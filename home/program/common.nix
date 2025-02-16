{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    gamescope
    repgrep
    frp
    bitwarden-desktop
    cargo
    yq-go
    pavucontrol # 音量控制GUI
    pamixer # 命令行音量控制
    pulseaudio # 提供一些命令行工具
    easyeffects # 音频效果器（可选）
    putty
    jellyfin-media-player
    go
    remmina
    node2nix
    dbeaver-bin
    dbgate
    mpv
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
