{
  mylib,
  dotfilesDir,
  config,
  ...
}:
let
  mkMutable = mylib.mkMutable dotfilesDir config;
in
{
  # Merge into one home.file attrset to satisfy statix W20 (repeated_keys).
  home.file.".pi/agent/extensions".source = mkMutable ./extensions;
  home.file.".pi/agent/themes".source = mkMutable ./themes;
  home.file.".pi/agent/prompts".source = mkMutable ./prompts;
}
