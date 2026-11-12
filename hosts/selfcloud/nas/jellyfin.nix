{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ffmpeg
    mediainfo
    libva-utils
  ];

  networking.firewall = {
    allowedTCPPorts = [ 8096 ];
    allowedUDPPorts = [
      1900
      7359
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    configDir = "/var/lib/jellyfin/config";
    cacheDir = "/var/cache/jellyfin";
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };
    forceEncodingConfig = true;
    transcoding = {
      hardwareDecodingCodecs = {
        h264 = true;
        mpeg2 = true;
        vc1 = true;
      };
      hardwareEncodingCodecs.hevc = true;
      # Haswell 不支持 HDR 硬件色调映射。
      enableToneMapping = false;
    };
  };
  systemd.services.jellyfin = {
    environment.LIBVA_DRIVER_NAME = "i965";
    # Merge proxy trust into the writable network config before Jellyfin loads it.
    preStart = lib.mkAfter /* py */ ''
      ${pkgs.python3}/bin/python3 - <<'PY'
      from pathlib import Path
      import xml.etree.ElementTree as ET

      path = Path("${config.services.jellyfin.configDir}/network.xml")
      tree = ET.parse(path) if path.exists() else ET.ElementTree(ET.Element("NetworkConfiguration"))
      root = tree.getroot()
      proxies = root.find("KnownProxies")
      if proxies is None:
          proxies = ET.SubElement(root, "KnownProxies")
      if not any(proxy.text == "127.0.0.1" for proxy in proxies):
          ET.SubElement(proxies, "string").text = "127.0.0.1"
          path.parent.mkdir(parents=True, exist_ok=True)
          tree.write(path, encoding="utf-8", xml_declaration=True)
      PY
    '';
  };
  users.users.jellyfin.extraGroups = [
    "video"
    "render"
    "fileshare"
  ];
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-vaapi-driver ];
  };
}
