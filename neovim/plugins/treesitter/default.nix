{
  scanPlugins,
  lib,
  ...
} @ args: let
  data =
    scanPlugins
    ./.
    args;
in
  lib.attrsets.mergeAttrsList data
