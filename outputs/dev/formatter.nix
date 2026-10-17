{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = {
    treefmt = {
      # The prek check already runs treefmt alongside the read-only linters.
      flakeCheck = false;
      flakeFormatter = true;
      programs = {
        # keep-sorted start block=yes
        deadnix.enable = true;
        keep-sorted.enable = true;
        nixfmt = {
          enable = true;
          width = 80;
        };
        ruff-check.enable = true;
        ruff-format.enable = true;
        # keep-sorted end
      };
      projectRootFile = "flake.nix";
      settings.global.excludes = [
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
}
