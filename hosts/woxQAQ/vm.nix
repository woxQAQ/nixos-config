{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
  services.flatpak.enable = true;

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
