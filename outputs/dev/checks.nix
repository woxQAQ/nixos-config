{ inputs, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];
  perSystem =
    { pkgs, ... }:
    {
      checks = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        catppuccin-appearance = import ../../home/public/catppuccin/check.nix {
          inherit pkgs;
          inherit (inputs) home-manager catppuccin;
        };
      };
      pre-commit = {
        check.enable = true;
        settings.package = pkgs.prek;
        settings.excludes = [ "flake.lock" ];

        settings.hooks = {
          # keep-sorted start block=yes
          actionlint.enable = true;
          statix.enable = true;
          treefmt.enable = true;
          # keep-sorted end
        };
      };
    };
}
