# Only the NixOS disk belongs to disko. The shared Windows ESP is mounted
# separately in storage.nix and must never be formatted by disko.
{
  disko.devices.disk.nixos = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Great_Wall_GT50_2TB_1618569D11160935352";
    content = {
      type = "gpt";
      partitions = {
        swap = {
          size = "16G";
          type = "8200";
          content = {
            type = "swap";
            priority = 10;
          };
        };
        root = {
          size = "100%";
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
    };
  };
}
