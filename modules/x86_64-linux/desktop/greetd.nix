{
  username,
  config,
  lib,
  ...
}:
let
  _env = config.modules.desktop.environment;
  iswayland = _env == "hyprland" || _env == "niri";
in
{
  config = lib.mkIf iswayland {
    services = {
      greetd = {
        enable = true;
        useTextGreeter = true;
        settings = rec {
          initial_session = {
            command = "$HOME/.wayland-session";
            user = username;
          };
          default_session = initial_session;
          terminal.vt = 1;
        };
      };
    };
  };
}
