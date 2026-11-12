{
  pkgs,
  username,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [ 8080 ]; # qBittorrent WebUI

  systemd.services.qbittorrent-nox = {
    description = "qBittorrent-nox";
    after = [
      "network.target"
      "mnt-data.mount"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = username;
      Group = "users";
      # Prefer interactive directory reads over background torrent I/O.
      IOSchedulingClass = "idle";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=/home/woxQAQ/.config/qBittorrent --webui-port=8080";
      Restart = "on-failure";
    };
  };
}
