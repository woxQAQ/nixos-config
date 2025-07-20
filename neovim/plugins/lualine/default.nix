{
  scanPlugins,
  lib,
  ...
}@args:
let
  data = lib.debug.traceVal (scanPlugins ./. args);
in
lib.attrsets.mergeAttrsList data
