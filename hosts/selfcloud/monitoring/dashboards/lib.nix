{ lib }:
{
  mkDashboard =
    attrs:
    {
      schemaVersion = 39;
      version = 1;
      timezone = "browser";
      refresh = "1m";
    }
    // attrs;

  mkPanel =
    { unit, ... }@attrs:
    lib.recursiveUpdate {
      fieldConfig.defaults = { inherit unit; };
      options = { };
    } (builtins.removeAttrs attrs [ "unit" ]);

  mkTarget =
    attrs:
    {
      refId = "A";
      legendFormat = "__auto";
    }
    // attrs;
}
