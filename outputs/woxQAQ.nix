{
  mylib,
  inputs,
  system,
  ...
}@args:
let
  name = "woxQAQ";
  nixos-modules = [
    inputs.agenix.nixosModules.default
    ../hosts/${name}
    ../modules/${system}/system
    ../modules/${system}/desktop
    ../modules/${system}/packages
    ../modules/${system}/boot
    ../modules/public
  ]
  ++ [
    {
      modules.desktop.game.enable = true;
    }
  ];
  home-modules = [
    ../home/nixos
    ../hosts/${name}/home.nix
  ]
  ++ [
    ../home/public
    {
      modules.public = {
        cloud-native.enable = true;
        desktop.enable = true;
        neovim.enable = true;
        terminal.font-size = 15;
      };
    }
  ]
  ++ [
    ../home/desktop
    {
      modules.desktop = {
        game.enable = true;
        browser = "chromium";
        fcitx5.enable = true;
      };
    }
  ];
  modules_ = {
    inherit nixos-modules home-modules;
    username = name;
  };
in
{
  nixosConfigurations = {
    "${name}" = mylib.mkHost (args // modules_);
  };
}
