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
  home-modules = [
    ../home/public
    ../home/nixos
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
