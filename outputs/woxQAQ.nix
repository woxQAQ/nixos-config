{
  mylib,
  inputs,
  ...
}@args:
let
  name = "woxQAQ";
in
{
  nixosConfigurations = {
    "${name}" = mylib.mkHost (
      args
      // {
        username = name;
        hostname = name;
        nixos-modules = [
          inputs.agenix.nixosModules.default
          inputs.dae.nixosModules.dae
          inputs.dae.nixosModules.daed
          ../secrets/linux.nix
          ../hosts/${name}
          ../modules/x86_64-linux/system
          ../modules/x86_64-linux/desktop
          ../modules/x86_64-linux/packages
          ../modules/x86_64-linux/boot
          ../modules/public
          ../modules/sandboxed/nixpaks
          ../modules/sandboxed/bwraps
          {
            modules.desktop = {
              browser = "zen";
              environment = "niri";
              fcitx5.enable = true;
              game.enable = true;
              flatpak-apps.enable = true;
            };
          }
        ];
        home-modules = [
          inputs.zen-browser.homeModules.beta
          ../home/nixos
          ../hosts/${name}/home.nix
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
          ../home/desktop
        ];
      }
    );
  };
}
