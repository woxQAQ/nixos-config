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
    # 类型 路径 模式 用户 组 清理策略
    "d /mnt/data 0755 ${username} users -"
    # 修复 ACL：子目录 group 权限只有 --x，需要改为 r-x 才能让 users 组读取
    "a /mnt/data/1000 - - - - group::r-x default:group::r-x"
    "a /mnt/data/1000/videos - - - - group::r-x default:group::r-x"
    "a /mnt/data/1000/data - - - - group::r-x default:group::r-x"
  ];
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/4617589b-04c3-4534-8c4a-9c4667116b6c";
    fsType = "btrfs";
    options = [
      "defaults"
      "noatime"
      "compress=zstd:1"
      "nofail"
      "space_cache=v2"
      "x-systemd.device-timeout=90"
    ];
  };
  environment.systemPackages = with pkgs; [
    mdadm
    lvm2
    btrfs-progs
    smartmontools
  ];
  # services.btrfs.autoScrub = {};
}
