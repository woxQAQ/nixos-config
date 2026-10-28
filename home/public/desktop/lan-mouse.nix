{
  lib,
  pkgs,
  config,
  mylib,
  dotfilesDir,
  ...
}:
let
  cfg = config.modules.public.desktop;
  package = pkgs.lan-mouse;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ package ];

    # Pairing state (authorized_fingerprints, GUI-managed clients) is written
    # back to this file by lan-mouse itself.
    xdg.configFile."lan-mouse/config.toml".source =
      mylib.mkMutable dotfilesDir config
        ./lan-mouse.toml;

    # On niri the layer-shell capture backend and the wlroots emulation backend
    # (virtual-pointer + virtual-keyboard) are used, both supported by niri.
    systemd.user.services.lan-mouse = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "lan-mouse software KVM daemon";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${package}/bin/lan-mouse daemon";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Note: the nix-built binary is ad-hoc signed, so macOS may ask again for
    # Input Monitoring / Accessibility permission after lan-mouse upgrades.
    launchd.agents.lan-mouse = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [
          "${package}/bin/lan-mouse"
          "daemon"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/lan-mouse.out.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/lan-mouse.err.log";
      };
    };
  };
}
