{ inputs, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];
  perSystem =
    { pkgs, ... }:
    {
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
