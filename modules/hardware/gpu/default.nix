{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.hardware.amd;
in
{
  options.modules.hardware.amd = with lib; {
    enable = mkEnableOption "amd gpu support";
    rocm.enable = mkEnableOption "amd rocm support";
  };
  config = lib.mkIf cfg.enable {
    hardware = {
      enableAllFirmware = true;
      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
      };
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          vulkan-tools
        ];
      };
    };

    services.lact = {
      enable = true;
    };
    nixpkgs.config.rocmSupport = cfg.rocm.enable;

    # Provide HIP/OpenCL runtime for AMD GPU compute.
    environment.systemPackages =
      with pkgs;
      [
        amdgpu_top
        nvtopPackages.amd
      ]
      ++ lib.optionals cfg.rocm.enable [
        rocmPackages.clr.icd
        rocmPackages.rocm-runtime
        rocmPackages.rocminfo
        clinfo
      ];
  };
}
