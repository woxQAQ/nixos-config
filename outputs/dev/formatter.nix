{
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    let
      statixConfig = lib.importTOML ../../statix.toml;
    in
    {
      treefmt = {
        flakeCheck = true;
        flakeFormatter = true;
        programs = {
          # keep-sorted start block=yes
          actionlint.enable = true;
          deadnix.enable = true;
          keep-sorted.enable = true;
          nixfmt.enable = true;
          ruff-check.enable = true;
          ruff-format.enable = true;
          statix = {
            enable = true;
            priority = -2;
            package = pkgs.statix;
            disabled-lints = statixConfig.disabled;
            excludes = statixConfig.ignore;
          };
          # keep-sorted end
        };
        projectRootFile = "flake.nix";
        settings = {
          nixfmt = {
            options = [
              "-w"
              "80"
            ];
          };
          global.excludes = [
            # keep-sorted start
            "*.gitignore"
            "*LICENSE"
            "*Makefile"
            "*flake.lock"
            ".envrc"
            # keep-sorted end
          ];
        };
      };
    };
}
