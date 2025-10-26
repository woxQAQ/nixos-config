{
  programs = {
    chromium = {
      enable = true;
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        "-enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
        "--gtk-version=4"
        "--enable-wayland-ime"
        "--proxy-server=127.0.0.1:7890"
      ];
    };
  };
}
