{
  scanPlugins = import ./scanPlugin.nix;
  keys = args: import ./getKeymapKeyAction.nix args;
}
