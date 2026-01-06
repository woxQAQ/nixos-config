{ pkgs, ... }:
let
  vibe-kanban = pkgs.callPackage ../../../pkg/vibe-kanban { };
in
{
  home.packages = [ vibe-kanban ];

  systemd.user.services.vibe-kanban = {
    Unit = {
      Description = "Vibe Kanban - AI coding agent orchestration tool";
      After = [ "network.target" ];
      Wants = [ "network.target" ];
    };

    Service = {
      ExecStart = "${vibe-kanban}/bin/vibe-kanban";
      Environment = [ "PORT=38891" ];
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
