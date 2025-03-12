{
  pkgs,
  inputs,
  system,
  ...
}: {
  programs = {
    chromium = {
      enable = true;
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        "-enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
      ];
    };
  };
  # home.packages = with pkgs; [
  #   inputs.zen-browser.packages.${system}.default
  # ];
}
