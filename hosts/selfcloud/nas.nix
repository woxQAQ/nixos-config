{
  pkgs,
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
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "selfcloud";
        # 协议优化
        "server min protocol" = "SMB3";
        "server max protocol" = "SMB3";
        "client min protocol" = "SMB3";

        # Socket 与网络优化
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=1058576 SO_SNDBUF=1058576";
        "use sendfile" = "yes";
        "max xmit" = "262144";
        # 异步 I/O（关键性能提升）
        "aio read size" = "1";
        "aio write size" = "1";
        "aio max threads" = "100";

        # 元数据缓存
        "stat cache" = "yes";
        "stat cache entries" = "50000";
        "directory name cache size" = "10000";

        # --- Btrfs 特定优化 ---
        "strict allocate" = "yes"; # 预分配减少 CoW 碎片
        "allocation roundup size" = "4096";

        # 禁用不必要属性（小文件性能）
        "store dos attributes" = "no";
        "map archive" = "no";
        "map hidden" = "no";
        "map system" = "no";

        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "woxQAQ"; # 修改为你的用户名
        "force group" = "users";
        "security" = "user";

        "inherit permissions" = "yes";
        "map to guest" = "never";
        "guest account" = "nobody";
      };
      "videos" = {
        path = "/mnt/data/1000/videos";
        browseable = "yes";
        "read only" = "yes"; # 媒体库建议只读，通过下载工具写入
        "valid users" = "woxQAQ";

        "strict sync" = "no";
        "sync always" = "no";
        "oplocks" = "yes";
        "level2 oplocks" = "yes";
      };
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    # 配置目录（系统盘，保留设置）
    configDir = "/var/lib/jellyfin/config";
    # 缓存目录（可放数据盘）
    cacheDir = "/mnt/data/.cache/jellyfin";
  };
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
  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];
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
      User = "woxQAQ";
      Group = "users";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=/home/woxQAQ/.config/qBittorrent --webui-port=8080";
      Restart = "on-failure";
      # 关键：确保能访问 RAID 设备
      DeviceAllow = [ "/dev/dri/renderD128 rw" ]; # 如果需要硬解（虽然 qbittorrent 不用，但保留）
    };
  };
}
