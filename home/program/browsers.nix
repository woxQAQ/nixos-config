{
  pkgs,
  config,
  username,
  ...
}:
{
  programs = {
    chromium = {
      enable = true;
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
      ];
    };
  };
}
