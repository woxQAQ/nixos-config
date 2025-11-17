{
  username,
  config,
  lib,
  ...
}:
let
  _env = config.modules.desktop.environment;
in
{
  config = lib.mkIf (_env == "hyprland") {
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
