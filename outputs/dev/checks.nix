{ inputs, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];
  perSystem = {
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
      };
    };
  };
}
