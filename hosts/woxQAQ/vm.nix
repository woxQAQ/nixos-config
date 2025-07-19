{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
  services.flatpak.enable = true;
  virtualisation = {
    waydroid.enable = true;

    containers = {
      enable = true;
    };
    docker = {
      enable = true;
      daemon.settings = {
        "features" = {
          "containerd-snapshotter" = true;
        };
        "registry-mirrors" = [
          "https://dockerproxy.net"
        ];
      };

      enableOnBoot = true;
    };
  };
}
