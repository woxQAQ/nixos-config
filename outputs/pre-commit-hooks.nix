{ inputs, ... }:
{
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt-rfc-style
          git
          nodePackages.prettier
          zsh
          prefetch-npm-deps
          deadnix
          ruff
        ];
        name = "dots";
        DIRENV_LOG_FORMAT = "";
        shellHook = ''
          echo "Welcome to dots devshell"
        '';
      };
      pre-commit = {
        check.enable = true;
        settings.excludes = [ "flake.lock" ];

        settings.hooks = {
          deadnix = {
            enable = true;
            settings = {
              edit = true;
            };
          };
          statix.enable = true;
          actionlint.enable = true;
          # prettier = {
          #   enable = true;
          #   excludes = [
          #     ".js"
          #     ".md"
          #     ".ts"
          #   ];
          # };
        };
      };
    };
}
