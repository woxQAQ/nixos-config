{ pkgs, ... }:
let
  waydroid-helper = pkgs.callPackage ../../pkg/waydroid-helper { };
in
{
  environment.systemPackages = with pkgs; [
    docker-compose
    bindfs
    waydroid-helper
  ];
  systemd = {
    packages = [ waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };

  programs = {
    virt-manager.enable = true;
  };
  virtualisation = {
    waydroid.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    containers = {
      enable = true;
    };
    docker = {
      enable = true;
      autoPrune.enable = true;
      daemon.settings = {
        "features" = {
          "containerd-snapshotter" = true;
        };
      };

      enableOnBoot = true;
    };
  };
}
