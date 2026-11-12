{ pkgs, ... }:
{
  imports = [
    ./nas/samba.nix
    ./nas/jellyfin.nix
    ./nas/qbittorrent.nix
    ./nas/sftpgo.nix
  ];

  environment.systemPackages = with pkgs; [
    nmap
    ncdu
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.netdev_max_backlog" = 5000;

    "fs.file-max" = 1048576;
  };
}
