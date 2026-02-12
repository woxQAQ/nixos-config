{
  geodb,
  ...
}:
{
  networking = {
    hostName = "woxQAQ";
  };
  # environment.systemPackages = with pkgs; [
  #   mosdns
  # ];
  services.daed = {
    enable = false;
    assetsPaths = [
      "${geodb}/geoip.dat"
      "${geodb}/geosite.dat"
    ];
    # assetsPaths = with geoip-pkg; [
    #   "${v2ray-geoip}/share/v2ray/geoip.dat"
    #   "${v2ray-domain-list-community}/share/v2ray/geosite.dat"
    # ];

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
  # environment.systemPackages = [
  #   sparkle
  # ];
}
