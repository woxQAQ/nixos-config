{
  pkgs,
  username,
  ...
}:
{

  nixpkgs.config.rocmSupport = true;
  hardware = {
    amdgpu.opencl.enable = true;
    enableAllFirmware = true;
  };

  # Provide HIP/OpenCL runtime for AMD GPU compute.

  # Useful tools and common BLAS components for matrix workloads.
  environment.systemPackages = with pkgs; [
    rocmPackages.clr.icd # OpenCL ICD
    rocmPackages.rocm-runtime
    rocmPackages.rocminfo # 查看 GPU 信息
    clinfo # OpenCL 信息查看
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
