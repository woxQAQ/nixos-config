{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    repgrep
    frp
    yq-go
    duf
    gdu

    pavucontrol
    pamixer
    pulseaudio
    go-musicfox
    easyeffects
    youtube-tui
    pot
    ripgrep
    jellyfin-media-player
    mpv

    leetgo
    libreoffice-still
    qbittorrent-enhanced
    obsidian
    freetube
    bitwarden-desktop

    # ssh desktop client
    remmina

    beekeeper-studio
    font-manager
    qq
    wl-clipboard
    obs-studio
    wineWowPackages.wayland
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
    go = {
      enable = true;
      goPath = "go";
    };
  };
}
