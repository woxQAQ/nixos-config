{ pkgs, stateVersion, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./storage.nix
    ./nix.nix
    ./boot.specified.nix
    ./rocm.nix
    ./vm.nix
    ./waydroid-houdini.nix
    ./cloud-native.nix
    ./openlogi.nix
    ./tailscale.nix
  ];

  networking.hostName = "woxQAQ";

  networking.firewall = {
    # Trust all traffic from LAN
    extraInputRules = ''
      ip saddr 192.168.31.0/24 accept
    '';
    # Trust all traffic from Tailscale
    trustedInterfaces = [ "tailscale0" ];
  };

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
      # Keep WebKit and graphics dependencies aligned with the system package set.
      package = pkgs.clash-verge-rev;
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
