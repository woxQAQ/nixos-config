{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # imports = [
  #   determinate.nixosModules.default
  # ];

  nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];

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
    settings.auto-optimise-store = true;
    channel.enable = false;
  };
}
