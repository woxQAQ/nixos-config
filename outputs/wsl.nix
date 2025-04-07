{
  mylib,
  inputs,
  system,
  ...
} @ args: let
  name = "wsl";
  inherit (inputs) nixos-wsl;
  nixos-modules = [
    inputs.nixvim.nixosModules.nixvim
    ../neovim
    nixos-wsl.nixosModules.wsl
    ../hosts/${name}
    ../modules/${system}/base
    ../modules/${system}/base.nix
    ../modules/public
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
