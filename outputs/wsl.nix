{
  mylib,
  inputs,
  system,
  ...
} @ args: let
  name = "wsl";
  nixos-modules = [
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
