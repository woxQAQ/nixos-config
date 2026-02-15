{ config, ... }:
let
  cfg = config.modules.desktop.browser;
in
{
  config.programs = {
    firefox.enable = true;
    zen-browser = {
      enable = true;
      # profiles."*" = {
      # };
    };
    chromium = {
      enable = cfg == "chromium";
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        "-enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
        "--gtk-version=4"
        "--enable-wayland-ime"
      ];
    };
  };
}
