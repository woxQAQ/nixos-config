{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixos config dev shells";
        shellHook = config.pre-commit.shellHook;
        packages = with pkgs; [
          # stdenv puts its minimal bash on PATH, which lacks programmable
          # completion (progcomp) and \[ \] prompt decoding, breaking
          # bash-completion and starship when we run `bash` in the dev shell.
          bashInteractive
          just
          nixfmt
          git
          prettier
          deadnix
          nix-prefetch-git
          ruff
          fzf
          jq
          statix
        ];
      };
    };
}
