{
  mylib,
  inputs,
  system,
  ...
}@args:
let
  name = "windows-vm1";
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
      modules.desktop.game.enable = false;
    }
  ];
  home-modules = [
    ../home/nixos
  ]
  ++ [
    ../home/public
    # {
    #   modules = {
    #     public.cloud-native.enable = false;
    #   };
    # }
  ]
  ++ [
    ../home/desktop
    {
      modules.desktop = {
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
