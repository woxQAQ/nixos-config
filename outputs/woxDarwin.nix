{
  mylib,
  inputs,
  system,
  ...
}@args:
let
  name = "woxMac";
  darwin-modules = [
    inputs.agenix.darwinModules.default
    ../secrets
    ../hosts/${name}
    ../modules/${system}
    ../modules/public
  ];
  home-modules = [
    ../home/darwin
  ]
  ++ [
    ../home/public
    {
      modules.public = {
        cloud-native.enable = true;
        desktop.enable = true;
        neovim.enable = true;
        helix.enable = true;
        terminal.font-size = 15;
      };
    }
  ];
  modules_ = {
    inherit darwin-modules home-modules;
    username = "woxqaq";
    hostname = name;
  };
in
{
  darwinConfigurations = {
    "${name}" = mylib.mkDarwin (args // modules_);
  };
}
