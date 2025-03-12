{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];
  programs.ags = {
    enable = true;
    configDir = ./src;
    extraPackages = [
      inputs.ags.packages.${pkgs.system}.hyprland
      inputs.ags.packages.${pkgs.system}.tray
    ];
  };
}
