{
  mylib,
  system,
  ...
} @ args: let
  name = "woxQAQ";
  nixos-modules = [
    ../hosts/${name}
    ../modules/${system}
    ../modules/${system}/boot
    ../modules/public
  ];
  home-modules = [
    ../home
    ../home/program
    ../home/desktop
    ../neovim
    ../home/fcitx
    ../home/public
  ];
  modules_ = {
    inherit nixos-modules home-modules;
    username = name;
  };
in {
  nixosConfigurations = {
    "${name}" = mylib.mkHost (args // modules_);
  };
}
