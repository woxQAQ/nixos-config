{
  mylib,
  inputs,
  system,
  ...
} @ args: let
  name = "woxQAQ";
  nixos-modules = [
    ../hosts/${name}
    ../modules/${system}
    ../modules/${system}/boot
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
  debug_ = {
    a = mylib.mkHost;
    mod = modules_;
    b = args // modules_;
  };
  nixosConfigurations = {
    "${name}" = mylib.mkHost (args // modules_);
  };
}
