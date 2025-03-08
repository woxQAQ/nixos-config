{inputs, ...}: let
  inherit (inputs) pkgs;
in {
  imports = [inputs.pre-commit-hooks.flakeModule];

  perSystem = {
    devShells.default = pkgs.mkShell {
      packages = [
        pkgs.alejandra
        pkgs.git
        pkgs.nodePackages.prettier
      ];
      name = "dots";
      DIRENV_LOG_FORMAT = "";
    };
  };
  perSystem.pre-commit = {
    settings.excludes = ["flake.lock"];

    settings.hooks = {
      alejandra.enable = true;
      prettier = {
        enable = true;
        excludes = [
          ".js"
          ".md"
          ".ts"
        ];
      };
    };
  };
}
