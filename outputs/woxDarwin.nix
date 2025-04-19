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
    ../home/public/nix
    ../home/public/terminal
    ../home/public/shell
    ../neovim
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
