{
  pkgs,
  username,
  ...
}:
{
  nixpkgs.config.rocmSupport = true;

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

  # Provide HIP/OpenCL runtime for AMD GPU compute.

  # Useful tools and common BLAS components for matrix workloads.
  environment.systemPackages = with pkgs; [
    rocmPackages.clr.icd # OpenCL ICD
    rocmPackages.rocm-runtime
    rocmPackages.rocminfo # 查看 GPU 信息
    clinfo # OpenCL 信息查看
    amdgpu_top
    nvtopPackages.amd
  ];

  # Keep compatibility path for software expecting amdgpu.ids under /opt/amdgpu.
  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];

  users.users.${username}.extraGroups = [
    "video"
    "render"
  ];
}
