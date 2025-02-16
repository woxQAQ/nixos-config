{ ... }:
{
  boot.loader.grub.extraEntries = ''
    menuentry "Windows" {
      search --file --no-floppy --set=root /EFI/Microsoft/Boot/bootmgfw.efi
      chainloader (''${root})/EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';
  hardware.amdgpu.initrd.enable = true;
}
