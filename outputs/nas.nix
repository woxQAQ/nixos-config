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
    ../modules/${system}/base.nix
    ../modules/${system}/boot
    ../modules/public
  ];
  home-modules = [
    ../home
    ../neovim
    ../home/public
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
