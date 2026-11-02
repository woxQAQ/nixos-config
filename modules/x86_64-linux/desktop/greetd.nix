{
  username,
  config,
  lib,
  pkgs,
  ...
}:
let
  _env = config.modules.desktop.environment;
  iswayland = _env == "hyprland" || _env == "niri";
in
{
  config = lib.mkIf iswayland {
    security.pam.services = {
      greetd.enableGnomeKeyring = true;
      passwd.enableGnomeKeyring = true;
    };
    programs = {
      seahorse.enable = true;
      gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
    };
    services = {
      xserver.enable = false;
      greetd = {
        enable = true;
        useTextGreeter = true;
        settings = rec {
          default_session = {
            user = username;
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd $HOME/.wayland-session"; # start wayland session with a TUI login manager
          };
          terminal.vt = 1;
        };
      };
    };
  };
}
