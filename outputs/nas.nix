{
  mylib,
  inputs,
  system,
  ...
} @ args: let
  name = "nas";
  nixos-modules = [
    inputs.nixvim.nixosModules.nixvim
    ../neovim
    ../hosts/${name}
    ../modules/${system}/base
    ../modules/base.nix
    ../modules/${system}/boot
  ];
  home-modules = [
    ../home
    ../neovim
    ../home/public
    ../home/fcitx
  ];
  modules_ = {
    inherit nixos-modules home-modules;
    username = "woxQAQ";
  };
in {
  nixosConfigurations = {
    "${name}" = mylib.mkHost (args // modules_);
  };
}
