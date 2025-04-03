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
  modules_ = {
    inherit nixos-modules;
    username = "woxQAQ";
  };
in {
  nixosConfigurations = {
    "${name}" = mylib.mkHost (args // modules_);
  };
}
