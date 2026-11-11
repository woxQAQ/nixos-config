{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ intel-gpu-tools ];
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "i915.fastboot=1"
      "enable_gvt=1"
    ];
  };
}
