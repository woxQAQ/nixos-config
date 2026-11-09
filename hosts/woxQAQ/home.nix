{
  pkgs,
  config,
  mylib,
  dotfilesDir,
  ...
}:

{
  # Keep GTK and SWT on the same integer scale under native Wayland.
  programs.dbeaver = {
    forceX11 = false;
    showSplash = false;
    environment = {
      DISPLAY = null;
      GDK_BACKEND = "wayland";
      GDK_SCALE = "2";
      GDK_DPI_SCALE = "1";
    };
    extraJavaOptions = [ "-Dswt.autoScale=200" ];
  };

  home.packages = with pkgs; [
    # clash-nyanpasu
    netease-cloud-music-gtk
    # n8n
    insomnia
    # notepad-next

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
    # qq - via nixpaks (modules/sandboxed/nixpaks)
    obs-studio
    wineWow64Packages.wayland
  ];
  # Keep launches on the Nix wrapper; upstream registers its unwrapped executable.
  xdg.dataFile."applications/magpie.desktop".source =
    "${pkgs.magpie}/share/applications/magpie.desktop";

  xdg.configFile."niri/niri-hardware.kdl".source =
    mylib.mkMutable dotfilesDir config
      ./niri-hardware.kdl;

  xdg.configFile."openlogi/config.toml".source =
    mylib.mkMutable dotfilesDir config
      ./openlogi.toml;

  # Noctalia v5 writes GUI-managed state to settings.toml; it follows the
  # symlink and writes through to this repo file, like v4's settings.json.
  home.file.".local/state/noctalia/settings.toml".source =
    mylib.mkMutable dotfilesDir config
      ./noctalia-settings.toml;

  programs.ssh.settings."github.com".IdentityFile =
    "${config.home.homeDirectory}/.ssh/id_ed25519";
}
