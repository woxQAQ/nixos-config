{
  pkgs,
  lib,
  config,
  ...
}@args:
let
  cfg = config.modules.desktop;
  enabled = cfg.environment == "niri";
in
{
  config = lib.mkIf enabled (
    lib.mkMerge [
      (import ./conf args)
      {
        home.packages = with pkgs; [
          xwayland-satellite
        ];
        systemd.user.services.niri-flake-polkit = {
          Unit = {
            Description = "PolicyKit Authentication Agent provided by niri-flake";
            After = [
              "graphical-session.target"
            ];
            Wants = [ "graphical-session-pre.target" ];
          };
          Install.WantedBy = [ "niri.service" ];
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
        home.file.".wayland-session" = {
          source = pkgs.writeScript "init-session" ''
            # trying to stop a previous niri session
            systemctl --user is-active niri.service && systemctl --user stop niri.service
            # and then we start a new one
            /run/current-system/sw/bin/niri-session
          '';
          executable = true;
        };
      }
    ]
  );
}
