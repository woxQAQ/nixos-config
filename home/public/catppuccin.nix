{ catppuccin, ... }:
{
  imports = [
    catppuccin.homeModules.catppuccin
  ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
    zed = {
      enable = false;
      flavor = "frappe";
      accent = "blue";
      icons.enable = false;
    };
  };
}
