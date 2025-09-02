{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = {
    treefmt = {
      flakeCheck = true;
      flakeFormatter = true;
      projectRootFile = "flake.nix";
      programs = {
        deadnix.enable = true;
        actionlint.enable = true;
        keep-sorted.enable = true;
        nixfmt.enable = true;
        ruff-check.enable = true;
        ruff-format.enable = true;
        statix.enable = true;
      };
      settings = {
        global.excludes = [
          # keep-sorted start

          ".envrc"
          "*flake.lock"
          "*.gitignore"
          "*LICENSE"
          "*Makefile"

          # keep-sorted end
        ];
      };
    };
  };
}
