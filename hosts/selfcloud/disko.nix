# 声明式磁盘布局：三块 HDD 组成 RAID5（md0），其上 LVM（VG trim_*）的
# LV 0 格式化为 btrfs 挂载到 /mnt/data。
#
# 该布局是对既有磁盘结构的描述，用于未来重装时复现。
# 绝不可在本机执行 disko 的 format/mount 脚本（diskoScript / diskDestroyScript），
# 那会重新分区并清空 RAID 数据。NixOS 模块只消费其中的 fileSystems/boot 配置。
let
  raidMember = device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions.mdadm = {
        size = "100%";
        content = {
          type = "mdraid";
          name = "md0";
        };
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      sda = raidMember "/dev/sda";
      sdc = raidMember "/dev/sdc";
      sdd = raidMember "/dev/sdd";
    };

    mdadm.md0 = {
      type = "mdadm";
      level = 5;
      content = {
        type = "lvm_pv";
        vg = "trim_c3edce3e_26e8_4bd3_a9fe_6d8c89a428fb";
      };
    };

    lvm_vg."trim_c3edce3e_26e8_4bd3_a9fe_6d8c89a428fb" = {
      type = "lvm_vg";
      lvs."0" = {
        size = "100%FREE";
        content = {
          type = "btrfs";
          mountpoint = "/mnt/data";
          mountOptions = [
            "noatime"
            "compress=zstd:1"
            "nofail"
            "x-systemd.device-timeout=90"
          ];
        };
      };
    };
  };
}
