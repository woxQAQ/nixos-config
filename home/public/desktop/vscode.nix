{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.public.vscode;
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      # Extensions are mostly installed ad-hoc from the marketplace; keep the
      # extension dir writable instead of pinning it through the store.
      mutableExtensionsDir = true;
      profiles.default = {
        userSettings = {
          # Nix manages updates; the app bundle in the store is read-only.
          "update.mode" = "none";
          "telemetry.telemetryLevel" = "off";
          "extensions.autoUpdate" = false;
        };
      };
    };
  };
}
