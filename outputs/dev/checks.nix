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
        # keep-sorted start block=yes
        actionlint.enable = true;
        deadnix = {
          enable = true;
          settings = {
            edit = true;
          };
        };
        statix.enable = true;
        # keep-sorted end
      };
    };
  };
}
