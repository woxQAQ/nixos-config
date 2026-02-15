{
  mylib,
  inputs,
  system,
  ...
}@args:
let
  name = "woxQAQ";
  nixos-modules = [
    inputs.agenix.nixosModules.default
    inputs.dae.nixosModules.dae
    inputs.dae.nixosModules.daed
    ../secrets
    ../hosts/${name}
    ../modules/${system}/system
    ../modules/${system}/desktop
    ../modules/${system}/packages
    ../modules/${system}/boot
    ../modules/public
  ]
  ++ [
    {
      modules = {
        desktop.game.enable = true;
        desktop.flatpak-apps.enable = true;
      };
    }
  ];
  home-modules = [
    inputs.zen-browser.homeModules.beta
    ../home/nixos
    ../hosts/${name}/home.nix
  ]
  ++ [
    ../home/public
    {
      modules.public = {
        cloud-native.enable = true;
        desktop.enable = true;
        neovim.enable = true;
        helix.enable = true;
        terminal.emulator = "ghostty";
        terminal.font-size = 15;
      };
    }
  ]
  ++ [
    ../home/desktop
    {
      modules.desktop = {
        game.enable = true;
        browser = "chromium";
        fcitx5.enable = true;
      };
    }
  ];
  niri-modules = {
    nixos-modules = nixos-modules ++ [
      {
        modules.desktop.environment = "niri";
      }
    ];
    home-modules = home-modules ++ [
      {
        modules.desktop.environment = "niri";
      }
    ];
    username = name;
  };
  # modules_ = {
  #   inherit nixos-modules home-modules;
  #   username = name;
  # };
in
{
  nixosConfigurations = {
    "${name}" = mylib.mkHost (args // niri-modules);
  };
}
