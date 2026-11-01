_:
let
  commonPort = [
    22
    7890
  ];
in
{
  networking = {
    timeServers = [
      "ntp.aliyun.com" # Aliyun NTP Server
      "ntp.tencent.com" # Tencent NTP Server
    ];
    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = commonPort;
      allowedUDPPorts = commonPort;
    };
    networkmanager.enable = true;
    nftables.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      domain = true;
      userServices = true;
    };
  };
}
