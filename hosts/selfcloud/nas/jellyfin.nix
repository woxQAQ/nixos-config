{ pkgs, ... }:
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
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "i965";
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
