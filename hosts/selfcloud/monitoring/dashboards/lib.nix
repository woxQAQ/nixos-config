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
    } (removeAttrs attrs [ "unit" ]);

  grid = x: y: w: h: {
    inherit
      x
      y
      w
      h
      ;
  };
  mkTarget =
    attrs:
    {
      refId = "A";
      legendFormat = "__auto";
    }
    // attrs;
}
