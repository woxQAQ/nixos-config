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
  services.lact = {
    enable = true;
  };

  networking = {
    hostName = "woxQAQ";
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs = {
    localsend.enable = true;
    clash-verge = {
      enable = true;
      autoStart = true;
      serviceMode = true;
      tunMode = true;
    };
  };
  system.stateVersion = stateVersion;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
