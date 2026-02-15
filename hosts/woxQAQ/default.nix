{
  stateVersion,
  fastest-pkg,
  geodb,
  ...
}:
let
  clash-verge = fastest-pkg.callPackage ../../pkg/clash-verge-rev { geoip = geodb; };
in
{
  imports = [
    ./hardware-configuration.nix
    ./boot.specified.nix
    ./vm.nix
    ./cloud-native.nix
    ./proxy.nix
    ./monitoring.nix
  ];
  # AMD graphics manage
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
      package = clash-verge;
      # The overlay in overlays/default.nix provides version 2.4.4
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
