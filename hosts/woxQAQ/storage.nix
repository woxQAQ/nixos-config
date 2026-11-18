{
  # This existing ESP also contains Windows Boot Manager. Keeping it outside
  # disko prevents repartitioning or formatting the Windows disk.
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/12AE-8021";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/98C2B1F5C2B1D828";
    fsType = "ntfs3";
    options = [
      "uid=1000"
      "gid=100"
      "umask=0077"
      "windows_names"
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
    ];
  };
}
