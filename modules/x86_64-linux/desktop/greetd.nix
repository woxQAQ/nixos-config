{
  pkgs,
  username,
  ...
}:
{
  services = {
    greetd = {
      enable = true;
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
}
