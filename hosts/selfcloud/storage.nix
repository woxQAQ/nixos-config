{
  pkgs,
  username,
  ...
}:
{
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      ARRAY /dev/md0 UUID=c2747d59-3c21-4097-fa97-a8e527cdb632
      PROGRAM ${pkgs.coreutils}/bin/true
    '';
  };
  services.lvm.enable = true;
  boot.initrd = {
    services.lvm.enable = true;
    availableKernelModules = [
      "dm_mod"
    ];
  };
  systemd.tmpfiles.rules = [
    "d /mnt/data 0755 ${username} users -"
    "a /mnt/data/1000 - - - - group::r-x,default:group::r-x"
    "a /mnt/data/1000/videos - - - - group::r-x,default:group::r-x"
    "a /mnt/data/1000/data - - - - group::r-x,default:group::r-x"
  ];

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
  environment.systemPackages = with pkgs; [
    mdadm
    lvm2
    btrfs-progs
    smartmontools
  ];
}
