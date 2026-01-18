{
  stateVersion,
  pkgs,
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
      package = pkgs.clash-verge-rev.overrideAttrs (
        _final: _prev: {
          version = "2.4.4";
          src = pkgs.fetchFromGitHub {
            owner = "clash-verge-rev";
            repo = "clash-verge-rev";
            tag = "v${_final.version}";
            hash = "sha256-GmoeOLKxdW1x6PHtslwNPVq8wDWA413NHA/VeDRb4mA=";
          };
        }
      );
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
