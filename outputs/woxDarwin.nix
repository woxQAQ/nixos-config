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
    ../hosts/${name}
    ../modules/${system}
    ../modules/public
    ../secrets/darwin.nix
    {
      modules.darwin = {
        rime.enable = true;
        brew.casks = [
          # keep-sorted start
          "feishu"
          # a gba emulators to play gba games
          "mgba-app"
          # Open broadcast studio
          "obs"
          "raycast"
          # keep-sorted end
        ];
      };
    }
  ];
  home-modules = [
    ../home/darwin
  ]
  ++ [
    ../home/agents
    {
      modules.agents = {
        profile = "terminal";
      };
    }
    ../home/public
    {
      modules.public = {
        cloud-native.enable = true;
        desktop.enable = true;
        neovim.enable = true;
        helix.enable = true;
        playwright.enable = true;
        terminal = {
          font-size = 15;
          font-family = "IoskeleyMonoTerm Nerd Font Mono";
        };
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
