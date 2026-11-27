{
  # This existing ESP also contains Windows Boot Manager. Keeping it outside
  # disko prevents repartitioning or formatting the Windows disk.
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/12AE-8021";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };
}
