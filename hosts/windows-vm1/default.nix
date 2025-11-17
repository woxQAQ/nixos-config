{
  stateVersion,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "windows-vm1";
  };
  # hardware.graphics = {
  #   enable = true;
  #   enable32Bit = true;
  # };
  boot.loader = {
    grub.device = "/dev/sda";
  };
  system.stateVersion = stateVersion;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
