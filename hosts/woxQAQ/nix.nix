{ lib, ... }:
{
  # buildGoModule forwards GOPROXY to fixed-output dependency fetchers.
  systemd.services.nix-daemon.environment.GOPROXY = "https://goproxy.cn,direct";

  nix.settings = {
    # All three endpoints serve cache.nixos.org-signed store paths.
    # Explicit priorities prefer mainland mirrors over the upstream cache.
    substituters = lib.mkForce [
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=10"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=20"
      "https://cache.nixos.org?priority=40"
    ];
    connect-timeout = 5;
    stalled-download-timeout = 20;
  };
}
