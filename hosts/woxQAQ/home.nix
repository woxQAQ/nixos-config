{
  pkgs,
  lib,
  config,
  mylib,
  dotfilesDir,
  ...
}:

{
  imports = [ ./waydroid-display.nix ];

  # Trust HTTPS certificates issued by selfcloud's Caddy internal CA in
  # browsers. They verify with NSS instead of the OpenSSL system store
  # populated by security.pki.certificateFiles.
  programs.firefox.policies.Certificates = {
    # Firefox keeps its own per-profile NSS database; install the root via
    # enterprise policy. ImportEnterpriseRoots also trusts the NixOS system
    # store via p11-kit, covering tools that read it that way.
    ImportEnterpriseRoots = true;
    Install = [ ../../cert/selfcloud-caddy-root.crt ];
  };

  # Chrome and Chromium read the shared NSS database at ~/.pki/nssdb.
  # Re-import on every switch to follow root rotation (e.g. server reinstalls).
  home.activation.trustSelfcloudCA = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    db="${config.home.homeDirectory}/.pki/nssdb"
    run mkdir -p "$db"
    if [ ! -f "$db/cert9.db" ]; then
      run ${pkgs.nss.tools}/bin/certutil -d "sql:$db" -N --empty-password
    fi
    run ${pkgs.nss.tools}/bin/certutil -d "sql:$db" -D -n selfcloud-caddy-root || true
    run ${pkgs.nss.tools}/bin/certutil -d "sql:$db" -A -t "C,," -n selfcloud-caddy-root -i ${../../cert/selfcloud-caddy-root.crt}
  '';

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
    github-desktop

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
      ./configs/niri-hardware.kdl;

  xdg.configFile."openlogi/config.toml".source =
    mylib.mkMutable dotfilesDir config
      ./openlogi/config.toml;

  # Noctalia v5 writes GUI-managed state to settings.toml; it follows the
  # symlink and writes through to this repo file, like v4's settings.json.
  home.file.".local/state/noctalia/settings.toml".source =
    mylib.mkMutable dotfilesDir config
      ./configs/noctalia-settings.toml;

  programs.ssh.settings."github.com".IdentityFile =
    "${config.home.homeDirectory}/.ssh/id_ed25519";
}
