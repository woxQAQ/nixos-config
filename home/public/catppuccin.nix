{
  catppuccin,
  pkgs,
  ...
}:
{
  imports = [
    catppuccin.homeModules.catppuccin
  ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
    starship.enable = pkgs.stdenv.isLinux;
    zed = {
      enable = false;
      flavor = "frappe";
      accent = "blue";
      icons.enable = false;
    };
  };
}
