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
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  # The macOS relaunch action expects an executable inside an .app bundle.
  # Keep the upstream bundle intact, including its ad-hoc signature.
  package =
    if isDarwin then
      let
        version = "0.11.0";
        src = pkgs.fetchurl {
          url = "https://github.com/feschber/lan-mouse/releases/download/v${version}/lan-mouse-macos-arm64.zip";
          hash = "sha256-X/mWXQW+fxJbHXW55yWdh07JiqCGzkABJSK8JUBlAKk=";
        };
      in
      pkgs.runCommand "lan-mouse-${version}"
        {
          inherit version;
          nativeBuildInputs = [ pkgs.unzip ];
          meta.platforms = [ "aarch64-darwin" ];
        }
        ''
          mkdir -p "$out/Applications"
          unzip -q ${src} -d "$out/Applications"
        ''
    else
      pkgs.lan-mouse;
  appPath = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}/Lan Mouse.app";
  logDir = "${config.home.homeDirectory}/Library/Logs";
in
{
  options.modules.public.desktop.lan-mouse.configFile = lib.mkOption {
    type = lib.types.path;
    default = ./lan-mouse.toml;
    description = "Mutable Lan Mouse configuration file in the dotfiles checkout.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];

    # Pairing state (authorized_fingerprints, GUI-managed clients) is written
    # back to this file by lan-mouse itself.
    xdg.configFile."lan-mouse/config.toml".source =
      mylib.mkMutable dotfilesDir config
        cfg.lan-mouse.configFile;

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

    # Use a stable, real bundle path for Launch Services and privacy grants.
    targets.darwin.copyApps.enable = lib.mkIf isDarwin true;
    home.activation.lanMouseAppReady = lib.mkIf isDarwin (
      lib.hm.dag.entryBetween [ "setupLaunchAgents" ] [ "copyApps" ] ""
    );

    # The app owns its daemon so Relaunch restarts both processes. This agent
    # only opens the app at login; KeepAlive would repeatedly run `open`.
    launchd.agents.lan-mouse = lib.mkIf isDarwin {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/open"
          "-g"
          "--env"
          "LAN_MOUSE_HIDDEN=1"
          "--stdout"
          "${logDir}/lan-mouse.out.log"
          "--stderr"
          "${logDir}/lan-mouse.err.log"
          appPath
        ];
        RunAtLoad = true;
        KeepAlive = false;
        StandardOutPath = "${logDir}/lan-mouse.out.log";
        StandardErrorPath = "${logDir}/lan-mouse.err.log";
      };
    };
  };
}
