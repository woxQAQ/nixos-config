{inputs, ...}: {
  imports = [inputs.pre-commit-hooks.flakeModule];

  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = [
        pkgs.alejandra
        pkgs.git
        pkgs.nodePackages.prettier
        pkgs.zsh
        pkgs.prefetch-npm-deps
      ];
      name = "dots";
      DIRENV_LOG_FORMAT = "";
      shellHook = ''
        exec ${pkgs.zsh}/bin/zsh
      '';
    };
    pre-commit = {
      check.enable = true;
      settings.excludes = ["flake.lock"];

      settings.hooks = {
        alejandra.enable = true;
        prettier = {
          enable = true;
          deadnix = {
            enable = true;
            settings = {
              edit = true;
            };
          };
          excludes = [
            ".js"
            ".md"
            ".ts"
          ];
        };
      };
    };
  };
}
