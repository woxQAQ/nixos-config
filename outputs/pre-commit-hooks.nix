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
        packages = [
          pkgs.nixfmt-rfc-style
          pkgs.git
          pkgs.nodePackages.prettier
          pkgs.zsh
          pkgs.prefetch-npm-deps
          pkgs.deadnix
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
