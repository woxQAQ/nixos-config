{
  osConfig,
  options,
  lib,
  ...
}:
let
  cfg = osConfig.modules.desktop.browser;
  hasZenBrowser = lib.hasAttrByPath [
    "programs"
    "zen-browser"
  ] options;
in
{
  config.programs = {
    firefox.enable = cfg == "firefox";
    chromium = {
      enable = true;
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        "-enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
        "--gtk-version=4"
        "--enable-wayland-ime"
      ];
    };
  }
  // lib.optionalAttrs hasZenBrowser {
    zen-browser = {
      enable = cfg == "zen";
      # profiles."*" = {
      # };
    };
  };
}
