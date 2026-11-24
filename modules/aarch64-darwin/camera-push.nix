{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.darwin.camera-push;
in
{
  options.modules.darwin.camera-push = {
    enable = lib.mkEnableOption "push the built-in camera to the NixOS host over RTSP";

    target = lib.mkOption {
      type = lib.types.str;
      default = "woxQAQ.local";
      description = "接收端地址；woxQAQ 通过 avahi 发布 mDNS，局域网内可直接解析";
    };

    rtspPort = lib.mkOption {
      type = lib.types.port;
      default = 8554;
      description = "接收端 mediamtx 的 RTSP 端口";
    };

    deviceIndex = lib.mkOption {
      type = lib.types.str;
      default = "0";
      description = ''
        avfoundation 视频设备序号。
        用 ffmpeg -f avfoundation -list_devices true -i "" 查看，一般 0 是 FaceTime 摄像头。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "camera-push" ''
        exec ${pkgs.ffmpeg}/bin/ffmpeg -hide_banner \
          -f avfoundation -pixel_format nv12 -framerate 30 -video_size 1280x720 \
          -i ${lib.escapeShellArg "${cfg.deviceIndex}:none"} -an \
          -c:v h264_videotoolbox -b:v 4M -f rtsp -rtsp_transport tcp \
          ${lib.escapeShellArg "rtsp://${cfg.target}:${toString cfg.rtspPort}/macbook"}
      '')
    ];
  };
}
