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
    ../modules/${system}
    ../modules/${system}/desktop
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
    ../home/program
    ../home/desktop
    ../home/fcitx
    ../home/public
  ]
  ++ [
    {
      modules = {
        cloud-native.enable = true;
        desktop = {
          enable = true;
          game.enable = true;
        };
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
