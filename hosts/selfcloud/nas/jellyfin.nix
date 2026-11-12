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
      1900 # DLNA/SSDP
      7359 # Jellyfin 服务发现
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    # 配置目录放系统盘，保留服务设置
    configDir = "/var/lib/jellyfin/config";
    # 缓存目录放系统 SSD，减少与媒体盘争抢 I/O
    cacheDir = "/var/cache/jellyfin";
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };
    # 启动时备份并更新 encoding.xml，转码设置由 Nix 管理。
    forceEncodingConfig = true;
    transcoding = {
      # Haswell 的 i965 驱动支持这些解码格式和 H.264 编码。
      hardwareDecodingCodecs = {
        h264 = true;
        mpeg2 = true;
        vc1 = true;
      };
      hardwareEncodingCodecs.hevc = true;
      enableHardwareEncoding = true;
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
    # Haswell 使用 i965 VA-API 驱动；iHD 面向更新的 Intel 核显。
    extraPackages = [ pkgs.intel-vaapi-driver ];
  };
}
