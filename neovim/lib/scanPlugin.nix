{
  mylib,
  lib,
  pkgs,
  ...
}: let
  importPath = path: args: let
    value = import path;
  in
    if builtins.isFunction value
    then value args
    else value;
in
  dir: importArgs: map (path: importPath path importArgs) (mylib.scanPath dir)
