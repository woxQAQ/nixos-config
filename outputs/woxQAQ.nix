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
          inputs.hidpipe.nixosModules.default
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
            modules.btrbk.enable = true;
          }
          {
            modules.flclash = {
              enable = true;
              user = name;
            };
          }
          {
            modules.desktop = {
              environment = "niri";
              fcitx5.enable = true;
              game.enable = true;
              flatpak-apps.enable = true;
            };
          }
          {
            # Linux 捕获端:niri-session 已把 WAYLAND_DISPLAY 导入
            # systemd 用户环境,边缘屏障随 graphical-session.target 启动。
            services.hidpipe = {
              enable = true;
              user = name;
              openFirewall = true;
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
