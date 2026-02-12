{
  pkgs,
  config,
  ...
}:

{
  home.packages = with pkgs; [
    # clash-nyanpasu
    netease-cloud-music-gtk
    # n8n
    insomnia
    # notepad-next
    # flclash

    pamixer
    go-musicfox
    youtube-tui

    leetgo
    obsidian
    bitwarden-desktop

    # ssh desktop client
    remmina

    font-manager
    # qq - migrated to flatpak
    obs-studio
    wineWowPackages.wayland
  ];
  xdg.configFile."niri/niri-hardware.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/hosts/woxQAQ/niri-hardware.kdl";

  programs.ssh.matchBlocks."github.com".identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
  systemd.user.services.win11-steamapps-symlink = {
    Unit = {
      Description = "Create symlink to Windows Steam library";
      After = [ "mnt-win11.mount" ];
      Requires = [ "mnt-win11.mount" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/ln -sf \"/mnt/win11/Program Files (x86)/Steam\" %h/win11-steamapps";
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
