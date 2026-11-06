{
  noctalia,
  pkgs,
  ...
}:
{
  imports = [
    noctalia.homeModules.default
  ];
  home.packages = with pkgs; [
    # required by noctalia's screen-recording plugin
    gpu-screen-recorder
  ];
  programs.noctalia.enable = true;
}
