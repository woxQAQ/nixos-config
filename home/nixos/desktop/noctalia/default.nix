{
  lib,
  noctalia,
  osConfig,
  pkgs,
  ...
}:
{
  imports = [
    noctalia.homeModules.default
  ];
  config = lib.mkIf (osConfig.modules.desktop.environment == "niri") {
    home.packages = with pkgs; [
      # Required by Noctalia's screen-recording plugin.
      gpu-screen-recorder
    ];
    programs.noctalia.enable = true;
  };
}
