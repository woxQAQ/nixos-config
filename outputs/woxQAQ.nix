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
          # Bootstrap without an agenix identity; restore secrets after rekeying.
          inputs.disko.nixosModules.disko
          inputs.dae.nixosModules.dae
          inputs.dae.nixosModules.daed
          ../hosts/${name}
          ../modules/x86_64-linux/system
          ../modules/x86_64-linux/desktop
          ../modules/x86_64-linux/packages
          (
            { pkgs, ... }:
            {
              modules.btop.package = pkgs.btop-rocm;
            }
          )
          ../modules/x86_64-linux/boot
          ../modules/public
          ../modules/sandboxed/nixpaks
          ../modules/sandboxed/bwraps
          {
            modules.desktop = {
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
          ../home/agents
          ../home/public
          {
            modules.public = {
              cloud-native.enable = true;
              desktop.enable = true;
              neovim.enable = true;
              helix.enable = true;
              playwright.enable = true;
              terminal.emulators = [ "ghostty" ];
              terminal.font-size = 15;
            };
          }
          ../home/nixos/desktop
        ];
      }
    );
  };
}
