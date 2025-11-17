{
  mylib,
  system,
  ...
}@args:
let
  name = "windows-vm1";
  nixos-modules = [
    ../hosts/${name}
    ../modules/${system}/packages
    ../modules/${system}/desktop
    ../modules/${system}/system
    # ../modules/${system}/boot
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
  ]
  ++ [
    ../home/desktop
    {
      modules.desktop = {
        fcitx5.enable = true;
        environment = "gnome";
      };
    }
  ];
  modules_ = {
    inherit nixos-modules home-modules;
    username = "woxQAQ";
  };
in
{
  nixosConfigurations = {
    "${name}" = mylib.mkHost (args // modules_);
  };
}
