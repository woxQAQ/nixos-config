{ pkgs, stateVersion, ... }:
{
  imports = [
    ./boot.specified.nix
    ./disko.nix
    ./hardware-configuration.nix

    ./storage.nix
    ./nix.nix
    ./vm.nix
    ./waydroid-houdini.nix
    ./openlogi
    ./monitoring.nix
  ];

  networking.hostName = "woxQAQ";

  # Trust HTTPS certificates issued by selfcloud's Caddy internal CA.
  security.pki.certificateFiles = [ ../selfcloud/caddy-root.crt ];

  networking.firewall = {
    # Trust all traffic from LAN
    extraInputRules = ''
      ip saddr 192.168.31.0/24 accept
    '';
    # Trust all traffic from Tailscale
    trustedInterfaces = [ "tailscale0" ];
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
