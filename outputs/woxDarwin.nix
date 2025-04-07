{
  mylib,
  system,
  ...
} @ args: let
  name = "woxMac";
  darwin-modules = [
    ../hosts/${name}
    ../modules/${system}
  ];
  home-modules = [
  ];
  modules_ = {
    inherit darwin-modules home-modules;
    username = "shirakami_yuki";
    hostname = name;
  };
in {
  darwinConfigurations = {
    "${name}" = mylib.mkDarwin (args // modules_);
  };
}
