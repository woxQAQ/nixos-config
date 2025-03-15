{pkgs, ...}: {
  networking = {
    networkmanager.enable = true;
    timeServers = [
      "ntp.aliyun.com" # Aliyun NTP Server
      "ntp.tencent.com" # Tencent NTP Server
    ];
    firewall = {
      enable = true;
      allowPing = false;
    };
  };
  environment.systemPackages = with pkgs; [
    mihomo-party
  ];
  environment.variables = {
    HTTPS_PROXY = "http://127.0.0.1:7890";
    HTTP_PROXY = "http://127.0.0.1:7890";
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
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };
}
