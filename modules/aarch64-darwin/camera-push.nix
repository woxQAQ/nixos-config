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
    # 必须用 agent 而非 daemon：摄像头受 TCC 保护，root 上下文拿不到权限。
    # 首次运行需在 macOS 系统设置中授予 ffmpeg 摄像头权限。
    # 若 nixpkgs 的 ffmpeg 缺少 avfoundation（ffmpeg -devices | grep avfoundation
    # 无输出），改用 brew 的 ffmpeg 并替换下面的路径。
    launchd.agents.camera-push = {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.ffmpeg}/bin/ffmpeg"
          "-hide_banner"
          "-loglevel"
          "error"
          "-f"
          "avfoundation"
          "-framerate"
          "30"
          "-video_size"
          "1280x720"
          "-i"
          "${cfg.deviceIndex}:none"
          "-c:v"
          "h264_videotoolbox"
          "-b:v"
          "4M"
          "-f"
          "rtsp"
          "-rtsp_transport"
          "tcp"
          "rtsp://${cfg.target}:${toString cfg.rtspPort}/macbook"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/camera-push.log";
        StandardErrorPath = "/tmp/camera-push.log";
      };
    };
  };
}
