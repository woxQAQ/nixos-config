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
          inputs.hidpipe.nixosModules.default
          ../hosts/${name}
          ../modules/x86_64-linux/system
          {
            modules.btrbk.enable = true;
          }
          ../modules/x86_64-linux/desktop
          {
            modules.desktop = {
              environment = "niri";
              fcitx5.enable = true;
              game.enable = true;
            };
          }
          ../modules/x86_64-linux/packages
          (
            { pkgs, ... }:
            {
              modules.btop.package = pkgs.btop-rocm;
            }
          )
          ../modules/x86_64-linux/boot
          ../modules/hardware/cpu
          ../modules/hardware/fans
          ../modules/hardware/gpu
          ../modules/hardware/opengl
          ../modules/hardware/storage
          ../modules/hardware/audio
          {
            modules.hardware = {
              opengl.enable = true;
              amd = {
                enable = true;
                rocm.enable = true;
              };
            };
          }
          ../modules/public
          ../modules/sandboxed/nixpaks
          ../modules/sandboxed/bwraps
          {
            modules.flclash = {
              enable = true;
              user = name;
            };
          }
          {
            # Linux 捕获端:niri-session 已把 WAYLAND_DISPLAY 导入
            # systemd 用户环境,边缘屏障随 graphical-session.target 启动。
            services.hidpipe = {
              enable = true;
              user = name;
              openFirewall = true;
              latencyStats = true;
              clipboard.enable = true;
            };
          }
        ];
        home-modules = [
          ../home/nixos
          ../hosts/${name}/home.nix
          ../home/agents
          {
            modules.agents = {
              profile = "full";
            };
          }
          ../home/public/profiles/workstation.nix
          {
            modules.public = {
              cloud-native.enable = true;
              zed.enable = true;
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
