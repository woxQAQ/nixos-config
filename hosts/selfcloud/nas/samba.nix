{ username, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [
      445
      139 # Samba
    ];
    allowedUDPPorts = [
      137
      138 # Samba NetBIOS
    ];
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
          "read only" = "no";
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
        # 发布 selfcloud.local 的 A/AAAA 记录，否则客户端能浏览到服务
        # 却解析不出主机地址，连接会失败
        addresses = true;
      };
      # 向局域网广播 SMB 服务，macOS Finder 的「网络」依赖此 mDNS 记录做发现
      # （wsdd 只对 Windows 有效）
      extraServiceFiles.smb = /* xml */ ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
          <service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=Xserve</txt-record>
          </service>
        </service-group>
      '';
    };
  };
}
