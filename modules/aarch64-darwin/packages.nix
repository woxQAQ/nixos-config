{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    iproute2mac
    coreutils
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default
    ffmpeg
  ];
}
