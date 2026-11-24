{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.mac-camera;

  videoDevice = "/dev/video${toString cfg.videoNr}";
  rtspUrl = "rtsp://127.0.0.1:${toString cfg.rtspPort}/macbook";
in
{
  options.modules.services.mac-camera = {
    enable = lib.mkEnableOption "relay the MacBook camera into a local virtual camera over RTSP";

    videoNr = lib.mkOption {
      type = lib.types.ints.positive;
      default = 10;
      description = "v4l2loopback 设备序号，设备节点为 /dev/video<N>";
    };

    rtspPort = lib.mkOption {
      type = lib.types.port;
      default = 8554;
      description = "mediamtx 的 RTSP 监听端口，MacBook 向该端口推流";
    };
  };

  config = lib.mkIf cfg.enable {
    # 内核态虚拟摄像头，对所有应用透明；exclusive_caps=1 是 Chrome 识别的关键
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.extraModprobeConfig = ''
      options v4l2loopback video_nr=${toString cfg.videoNr} card_label="MacBook Camera" exclusive_caps=1
    '';

    # mediamtx 做推流端与消费端的中转，Mac 断开后可自动重连。
    # 只开 RTSP：其余协议端口（如 HLS 的 8888）在本机有占用，且无使用场景。
    # 只放行内网（含 tailnet）推流，且只允许本机 relay 读流。
    services.mediamtx = {
      enable = true;
      settings = {
        rtspAddress = ":${toString cfg.rtspPort}";
        rtmp = false;
        hls = false;
        webrtc = false;
        srt = false;
        authInternalUsers = [
          {
            user = "any";
            ips = [
              "192.168.31.0/24"
              "100.64.0.0/10"
            ];
            permissions = [
              {
                action = "publish";
                path = "macbook";
              }
            ];
          }
          {
            user = "any";
            ips = [ "127.0.0.1/32" ];
            permissions = [
              {
                action = "read";
                path = "macbook";
              }
            ];
          }
        ];
      };
    };

    # 无流时 ffmpeg 立即退出，交给 systemd 低频重试，代价可忽略
    systemd.services.mac-camera-relay = {
      description = "Relay the MacBook RTSP stream into the v4l2loopback device";
      after = [ "mediamtx.service" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.ffmpeg}/bin/ffmpeg -hide_banner -loglevel error \
            -rtsp_transport tcp -fflags nobuffer \
            -i ${rtspUrl} \
            -f v4l2 -pix_fmt yuv420p ${videoDevice}
        '';
        Restart = "always";
        RestartSec = 5;
        DynamicUser = true;
        SupplementaryGroups = [ "video" ];
      };
    };
  };
}
