{
  catppuccin,
  ...
}:
{
  imports = [
    catppuccin.homeModules.catppuccin
  ];
  catppuccin = {
    autoEnable = true;
    enable = true;
    flavor = "mocha";
    accent = "pink";
    # starship.enable = pkgs.stdenv.hostPlatform.isLinux;
    starship.enable = false;
    vscode.profiles.default.enable = false;
    zed = {
      enable = false;
      flavor = "frappe";
      accent = "blue";
      icons.enable = false;
    };
  };
}
