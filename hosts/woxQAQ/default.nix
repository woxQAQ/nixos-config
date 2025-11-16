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
