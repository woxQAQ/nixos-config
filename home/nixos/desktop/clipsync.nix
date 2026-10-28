# Wayland <-> X11 clipboard sync (pkg/clipsync), for compositors that run
# X11 apps through xwayland-satellite (niri, Hyprland, ...). The daemon
# needs DISPLAY + WAYLAND_DISPLAY from the graphical session, so it is
# bound to graphical-session.target.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.clipsync;
in
{
  options.services.clipsync.enable = lib.mkEnableOption "clipsync, the Wayland <-> X11 clipboard sync daemon";

  config = lib.mkIf cfg.enable {
    systemd.user.services.clipsync = {
      Unit = {
        Description = "Wayland <-> X11 clipboard sync (clipsync)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${lib.getExe pkgs.clipsync}";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 5;
      };
    };
  };
}
