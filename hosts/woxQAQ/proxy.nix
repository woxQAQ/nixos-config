{
  geodb,
  ...
}:
{
  services.daed = {
    enable = false;
    assetsPaths = [
      "${geodb}/geoip.dat"
      "${geodb}/geosite.dat"
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
