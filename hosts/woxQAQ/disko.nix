# The GPT and Windows partitions (p1-p4) are managed outside disko.
# Only the Linux partitions in the former free range belong to disko:
#   p5: 1074595840..1108150271, 16 GiB swap (type 8200)
#   p6: 1108150272..1998706687, remaining space, Btrfs (type 8300)
# Address partitions directly so disko never wipes the shared disk's GPT.
# The existing Windows ESP is mounted separately by storage.nix.
let
  disk = "/dev/disk/by-id/nvme-Predator_SSD_GM7_M.2_1TB_PSBH43440200531";
in
{
  disko.devices.disk = {
    swap = {
      type = "disk";
      device = "${disk}-part5";
      content = {
        type = "swap";
        priority = 10;
      };
    };
    root = {
      type = "disk";
      device = "${disk}-part6";
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          root = {
            mountpoint = "/";
            mountOptions = [ "compress=zstd" ];
          };
          home = {
            mountpoint = "/home";
            mountOptions = [ "compress=zstd" ];
          };
          nix = {
            mountpoint = "/nix";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };
        };
      };
    };
  };
}
