{
  mylib,
  inputs,
  system,
  ...
}@args:
let
  name = "woxMac-m1";
  darwin-modules = [
    inputs.agenix.darwinModules.default
    ../secrets/darwin.nix
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
        cloud-native.enable = false;
        desktop.enable = true;
        neovim.enable = false;
        helix.enable = true;
        agent.enable = false;
        playwright.enable = false;
        terminal = {
          font-size = 15;
          font-family = "IoskeleyMonoTerm Nerd Font Mono";
        };
      };
    }
  ];
  modules_ = {
    inherit darwin-modules home-modules;
    username = "shirakami_yuki";
    hostname = name;
  };
in
{
  darwinConfigurations = {
    "${name}" = mylib.mkDarwin (args // modules_);
  };
}
