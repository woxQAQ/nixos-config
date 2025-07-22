{
  services.k3s = {
    enable = false;
    role = "server";
  };
  # networking = {
  #   firewall.allowedTCPPorts = [ 6443 ];
  # };
}
