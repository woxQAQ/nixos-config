{mylib}:
# Simplified plugin scanning function
# Usage: scanPlugin directory {inherit lib pkgs;}
dir: importArgs: let
  # Import a single plugin file
  importPlugin = path: let
    value = import path;
  in
    if builtins.isFunction value
    then value importArgs
    else value;
in
  # Scan directory and import all found plugins
  map importPlugin (mylib.scanPath dir)
