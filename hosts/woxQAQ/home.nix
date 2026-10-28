{
  pkgs,
  config,
  mylib,
  dotfilesDir,
  ...
}:

{
  home.packages = with pkgs; [
    # clash-nyanpasu
    netease-cloud-music-gtk
    # n8n
    insomnia
    # notepad-next
    flclash

    pamixer
    go-musicfox
    youtube-tui

    leetgo
    magpie
    obsidian
    bitwarden-desktop

    # ssh desktop client
    remmina

    font-manager
    # qq - migrated to flatpak
    obs-studio
    wineWow64Packages.wayland
  ];
  # Keep launches on the Nix wrapper; upstream registers its unwrapped executable.
  xdg.dataFile."applications/magpie.desktop".source =
    "${pkgs.magpie}/share/applications/magpie.desktop";

  xdg.configFile."niri/niri-hardware.kdl".source =
    mylib.mkMutable dotfilesDir config
      ./niri-hardware.kdl;

  programs.ssh.settings."github.com".IdentityFile =
    "${config.home.homeDirectory}/.ssh/id_ed25519";
}
