{ pkgs, ... }:
{
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        # Keep kernels and GRUB data on the Linux filesystem; the shared
        # 400 MiB ESP only needs the EFI executable.
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        device = "nodev";
        default = 0;
        configurationLimit = 10;
        extraEntries = ''
          menuentry "Windows 11" {
            search --fs-uuid --no-floppy --set=root 12AE-8021
            chainloader (''${root})/EFI/Microsoft/Boot/bootmgfw.efi
          }
          menuentry "UEFI Firmware Settings" {
            fwsetup
          }
        '';
      };
    };

    # Use the standard kernel to benefit from the official binary cache.
    kernelPackages = pkgs.linuxPackages;
  };
  hardware.amdgpu.initrd.enable = true;
}
