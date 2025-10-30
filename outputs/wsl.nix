{
  mylib,
  inputs,
  system,
  ...
}@args:
let
  name = "wsl";
  nixos-modules = [
    inputs.nixos-wsl.nixosModules.wsl
    ../hosts/${name}
    ../modules/${system}
    ../modules/public
  ];
  modules_ = {
    inherit nixos-modules;
    username = "woxQAQ";
  };
in
{
  nixosConfigurations = {
    "${name}" = mylib.mkHost (args // modules_);
  };
}
