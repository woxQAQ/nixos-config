{
  pkgs,
  lib,
  username,
  config,
  ...
}:
let
  cfg = config.modules.hardware.opengl;
in
{
  options.modules.hardware.opengl = {
    enable = lib.mkEnableOption "opengl support";
  };
  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
        libva
        libvdpau
        libdrm
      ];
    };

    environment.systemPackages = with pkgs; [
      libva-utils
      vdpauinfo
    ];

    users.users.${username}.extraGroups = [
      "video"
      "render"
    ];
  };
}
