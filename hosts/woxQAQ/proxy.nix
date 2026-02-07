{ geoip-pkg, ... }:
{
  networking = {
    hostName = "woxQAQ";
  };
  services.daed = {
    enable = true;
    assetsPaths = with geoip-pkg; [
      "${v2ray-geoip}/share/v2ray/geoip.dat"
      "${v2ray-domain-list-community}/share/v2ray/geosite.dat"
    ];

    openFirewall = {
      enable = true;
      port = 12345;
    };

    /*
      default options

      package = inputs.daeuniverse.packages.x86_64-linux.daed;
      configDir = "/etc/daed";
      listen = "127.0.0.1:2023";
    */
  };
}
