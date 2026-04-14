{
  inputs,
  lib,
  self,
  pkgs,
  ...
}:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];
  perSystem = {
    pre-commit = {
      check.enable = false;
      settings.excludes = [ "flake.lock" ];

      settings.hooks = {
        # keep-sorted start block=yes
        actionlint.enable = true;
        deadnix = {
          enable = false;
          settings = {
            edit = true;
          };
        };
        statix.enable = true;
        treefmt.enable = true;
        # keep-sorted end
      };
    };

    checks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (
      lib.mapAttrs' (name: cfg: {
        name = "darwin-${name}";
        value = cfg.system;
      }) self.darwinConfigurations
    );
  };
}
