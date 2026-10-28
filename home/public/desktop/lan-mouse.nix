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

  # Upstream release bundle (ad-hoc signed, with gtk dylibs vendored). Pinning
  # the artifact keeps the binary byte-identical across unrelated nixpkgs
  # updates, so the macOS Input Monitoring grant survives until we deliberately
  # bump `version` here. The nixpkgs build relinks against moving gtk4 inputs
  # and would invalidate the (cdhash-based) grant far more often.
  lan-mouse-app = pkgs.fetchzip {
    name = "lan-mouse-0.11.0-macos";
    url = "https://github.com/feschber/lan-mouse/releases/download/v0.11.0/lan-mouse-macos-arm64.zip";
    hash = "sha256-0vAdCaWCoW0Us/GiU2jESQREaQj2tNojsiubdPD+opM=";
    stripRoot = false;
  };

  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  bin =
    if isDarwin then
      "${lan-mouse-app}/Lan Mouse.app/Contents/MacOS/lan-mouse"
    else
      "${pkgs.lan-mouse}/bin/lan-mouse";
in
{
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (!isDarwin) [ pkgs.lan-mouse ];

    # Expose the .app to LaunchServices (Spotlight, `open -a`) for the pairing GUI.
    home.file."Applications/Lan Mouse.app" = lib.mkIf isDarwin {
      source = "${lan-mouse-app}/Lan Mouse.app";
    };

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
        ExecStart = "${bin} daemon";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # First run requires granting Input Monitoring / Accessibility to the
    # (unsigned) bundle; the grant stays valid until `lan-mouse-app` above is
    # bumped to a new release.
    launchd.agents.lan-mouse = lib.mkIf isDarwin {
      enable = true;
      config = {
        ProgramArguments = [
          bin
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
