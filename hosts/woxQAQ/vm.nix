{ pkgs, ... }:
let
  _helper = pkgs.callPackage ../../pkg/waydroid-helper { };
in
{
  environment.systemPackages = with pkgs; [
    docker-compose
    bindfs
    _helper
    # waydroid-helper.overrideAttrs
    # (_final: _prev: {
    #   version = "0.2.9";
    #
    #   src = fetchFromGitHub {
    #     owner = "ayasa520";
    #     repo = "waydroid-helper";
    #     tag = "v${version}";
    #     hash = "sha256-I8DwaPQQz4eSyuTCwkbidhXACfpdOYcmGjP7d03DIU0=";
    #   };
    # })
  ];
  services.flatpak.enable = true;
  systemd = {
    packages = [ _helper ];
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
        # ovmf = {
        #   enable = true;
        #   packages = [ pkgs.OVMFFull.fd ];
        # };
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
        # "registry-mirrors" = [
        #   "https://docker.m.daocloud.io"
        #   "https://w9cn84cl.mirror.aliyuncs.com"
        # ];
        proxies = {
          "http-proxy" = "http://127.0.0.1:7890";
          "https-proxy" = "http://127.0.0.1:7890";
        };
      };

      enableOnBoot = true;
    };
  };
}
