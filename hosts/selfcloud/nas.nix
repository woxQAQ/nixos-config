{
  pkgs,
  username,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    nmap
    ffmpeg
    mediainfo
    ncdu
  ];
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        445
        139 # Samba
        8096 # Jellyfin
        8080 # qBittorrent WebUI（如需外网访问建议改端口）
      ];
      allowedUDPPorts = [
        137
        138 # Samba NetBIOS
        1900
        7359 # Jellyfin 服务发现
      ];
    };
  };
  services = {
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "selfcloud";

          # 局域网读多写少场景下，保留 SMB3 与必要项，避免过度调参
          "server min protocol" = "SMB3";
          "server max protocol" = "SMB3";
          "client min protocol" = "SMB3";
          "use sendfile" = "yes";

          "store dos attributes" = "no";
          "map archive" = "no";
          "map hidden" = "no";
          "map system" = "no";

          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = username;
          "force group" = "users";
          "security" = "user";

          "inherit permissions" = "yes";
          "map to guest" = "never";
          "guest account" = "nobody";
        };
        "videos" = {
          path = "/mnt/data/1000/videos";
          browseable = "yes";
          "read only" = "yes";
          "valid users" = username;
          "oplocks" = "yes";
        };
        "data" = {
          path = "/mnt/data/1000/data";
          browseable = "yes";
          "read only" = "no";
          "valid users" = username;
          "oplocks" = "yes";
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    avahi = {
      enable = true;
      openFirewall = true;
      publish = {
        enable = true;
        domain = true;
      };
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    # 配置目录放系统盘，保留服务设置
    configDir = "/var/lib/jellyfin/config";
    # 缓存目录放系统 SSD，减少与媒体盘争抢 I/O
    cacheDir = "/var/cache/jellyfin";
  };
  users.users.jellyfin.extraGroups = [
    "videos"
    "render"
    "users"
  ];
  # 确保 jellyfin (users 组) 能访问媒体子目录
  systemd.tmpfiles.rules = [
    "d /mnt/data/1000 0755 jellyfin users -"
    "d /mnt/data/1000/videos 0755 jellyfin users -"
  ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libvdpau-va-gl
      intel-vaapi-driver
    ];
  };
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    "net.ipv4.tcp_congestion_control" = "bbr"; # 高带宽延迟积网络优化
    "net.core.netdev_max_backlog" = 5000;

    # 文件描述符
    "fs.file-max" = 1048576; # Btrfs 异步写优化
  };
  # 自定义服务，明确以 woxQAQ 运行
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
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=/home/woxQAQ/.config/qBittorrent --webui-port=8080";
      Restart = "on-failure";
      # 关键：确保能访问 RAID 设备
      DeviceAllow = [ "/dev/dri/renderD128 rw" ]; # 如果需要硬解（虽然 qbittorrent 不用，但保留）
    };
  };
}
