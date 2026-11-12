{ lib, pkgs, ... }:
let
  dashboards = {
    storage = import ./storage.nix { inherit lib; };
    node-exporter = import ./node-exporter.nix { inherit lib; };
  };
in
{
  services.grafana.provision.dashboards.settings.providers = [
    {
      name = "selfcloud-storage";
      orgId = 1;
      folder = "Selfcloud";
      type = "file";
      disableDeletion = true;
      options.path = pkgs.linkFarm "selfcloud-dashboards" (
        lib.mapAttrsToList (name: dashboard: {
          name = "${name}.json";
          path = pkgs.writeText "${name}.json" (builtins.toJSON dashboard);
        }) dashboards
      );
    }
  ];
}
