{
  lib,
  pkgs,
  ...
}:
{
  # imports = [
  #   determinate.nixosModules.default
  # ];

  nix = {
    package = pkgs.nixVersions.latest;
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "cgroups" ];
      extra-sandbox-paths = [
        "/dev/net"
      ];
    };
    channel.enable = false;
  };
}
