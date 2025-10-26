{
  stateVersion,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.specified.nix
    ./vm.nix
    ./cloud-native.nix
  ];

  networking = {
    networkmanager.enable = true;
    hostName = "woxQAQ";
  };
  hardware.graphics = {
    enable = true;

    enable32Bit = true;
  };
  system.stateVersion = stateVersion;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
