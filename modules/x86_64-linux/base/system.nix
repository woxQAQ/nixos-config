{ lib, pkgs, ... }:
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
  };
}
