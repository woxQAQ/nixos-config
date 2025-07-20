{
  scanPlugins = import ./scanPlugin.nix;
  icons = import ./icons.nix;
  keys = args: import ./getKeymapKeyAction.nix args;
}
