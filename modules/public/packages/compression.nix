{ pkgs, ... }:
{
  # environment.variables.EDITOR = "nvim --clean";
  environment.systemPackages = with pkgs; [
    ### COMPRESSION
    zstd
    zip
    lz4
    p7zip
    unrar
    unar
    unzipNLS
    xz
  ];
}
