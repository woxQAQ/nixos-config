{
  lib,
  username,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    2022 # SFTP
    8081 # Web Admin / Web Client
  ];

  services.sftpgo = {
    enable = true;
    # 与 Samba、qBittorrent 保持相同的文件属主，复用现有数据目录权限。
    user = username;
    group = "users";
    extraReadWriteDirs = [
      "/mnt/data/1000/sftpgo"
      "/mnt/data/1000/data"
      "/mnt/data/1000/videos"
    ];
    settings = {
      data_provider = {
        driver = "sqlite";
        name = "sftpgo.db";
        users_base_dir = "/mnt/data/1000/sftpgo";
      };
      sftpd.bindings = [
        {
          address = "0.0.0.0";
          port = 2022;
        }
      ];
      httpd.bindings = [
        {
          address = "0.0.0.0";
          port = 8081;
          enable_web_admin = true;
          enable_web_client = true;
        }
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data/1000/sftpgo 0755 ${username} users -"
  ];
  systemd.services.sftpgo = {
    unitConfig.RequiresMountsFor = [ "/mnt/data" ];
    # 上传文件允许媒体服务读取，与 Samba 的文件权限一致。
    serviceConfig.UMask = lib.mkForce "0022";
  };
}
