{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale = {
    enable = false;
    port = 41641;
    interfaceName = "tailscale0";
    openFirewall = true;
    useRoutingFeatures = "client";
    extraSetFlags = [ "--accept-routes" ];
  };
}
