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
      ];
      name = "dots";
      DIRENV_LOG_FORMAT = "";
    };
    pre-commit = {
      check.enable = false;
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
