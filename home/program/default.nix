{pkgs,...}: {
  imports = [
    # ./rofi.nix
  ];

  home.packages = with pkgs; [
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

}
