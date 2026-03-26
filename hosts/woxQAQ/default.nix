{ stateVersion, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.specified.nix
    ./rocm.nix
    ./vm.nix
    ./cloud-native.nix
    ./proxy.nix
    ./monitoring.nix
    ./logid.nix
  ];

  networking.hostName = "woxQAQ";

  services.lact = {
    enable = true;
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
      group = "wheel";
    };
  };

  system.stateVersion = stateVersion;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
