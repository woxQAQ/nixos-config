{
  mylib,
  inputs,
  system,
  ...
} @ args: let
  name = "wsl";
  inherit nixos-wsl;
  nixos-modules = [
    nixos-wsl.nixosModules.wsl
    ../hosts/${name}
    ../modules/${system}
    ../modules/base.nix
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
