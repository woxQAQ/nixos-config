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
      # 依赖 bfq 调度器（见 ../storage.nix 的 udev 规则），mq-deadline 下此设置无效。
      IOSchedulingClass = "idle";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=/home/woxQAQ/.config/qBittorrent --webui-port=8080";
      Restart = "on-failure";
    };
  };
}
