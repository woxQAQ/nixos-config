{ pkgs, ... }:
{
  boot = {
    loader.grub = {
      device = "nodev";
      default = 0;
      extraEntries = ''
        menuentry "Windows" {
          search --file --no-floppy --set=root /EFI/Microsoft/Boot/bootmgfw.efi
          chainloader (''${root})/EFI/Microsoft/Boot/bootmgfw.efi
        }
        menuentry "UEFI Firmware Settings" {
          fwsetup
        }
      '';
    };
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };
  hardware.amdgpu.initrd.enable = true;
}
