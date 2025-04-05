{
  mylib,
  inputs,
  system,
  ...
} @ args: let
  name = "woxMac";
  darwin-modules = [
    ../hosts/${name}
    ../modules/aarch64-darwin
  ];
  home-modules = [
  ];
  modules_ = {
    inherit darwin-modules home-modules;
    username = name;
  };
in {
  darwinConfigurations = {
    "${name}" = mylib.mkDarwin (args // modules_);
  };
}
