{
  mylib,
  inputs,
  system,
  ...
} @ args: let
  name = "woxMac";
  darwin-modules = [
    ../hosts/${name}
    ../modules/${system}
    ../modules/public
  ];
  home-modules = [
    ../home/darwin
    ../home/public
    ../neovim
    ../hosts/${name}/home.nix
  ];
  modules_ = {
    inherit darwin-modules home-modules;
    username = "woxqaq";
    hostname = name;
  };
in {
  darwinConfigurations = {
    "${name}" = mylib.mkDarwin (args // modules_);
  };
}
