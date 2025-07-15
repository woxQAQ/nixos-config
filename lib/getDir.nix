current_dir: target_file:
let
  inherit (builtins)
    readDir
    pathExists
    filter
    attrNames
    ;
  contents = readDir current_dir;
  hasTargetFile =
    name: type: type == "directory" && pathExists (current_dir + "/${name}/${target_file}");
in
filter (name: hasTargetFile name contents.${name}) (attrNames contents)
