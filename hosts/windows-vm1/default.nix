{
  stateVersion,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    networkmanager.enable = true;
    hostName = "windows-vm1";
  };
  # hardware.graphics = {
  #   enable = true;
  #   enable32Bit = true;
  # };
  system.stateVersion = stateVersion;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
