{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = {
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
        statix.enable = true;
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
