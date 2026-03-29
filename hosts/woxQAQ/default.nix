{ pkgs, stateVersion, ... }:
let
  dnscryptForwardingRules = pkgs.writeText "dnscrypt-forwarding-rules.txt" ''
    ##################################
    #        Forwarding rules        #
    ##################################

    ## Route the homelab .lan zone to the router DNS server.
    lan 192.168.31.1
  '';
in
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

  services.dnscrypt-proxy.settings.forwarding_rules = dnscryptForwardingRules;

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
