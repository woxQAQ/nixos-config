{
  current_dir ? ./.,
  target_file ? "default.nix",
}: let
  contents = builtins.readDir current_dir;
  hasTargetFile = name: type:
    type == "directory" && builtins.pathExists (current_dir + "/${name}/${target_file}");
  getDir =
    builtins.filter
    (name: hasTargetFile name contents.${name})
    (builtins.attrNames current_dir);
in
  getDir
