{
  mylib,
  dotfilesDir,
  config,
  lib,
  ...
}:
let
  mkMutable = mylib.mkMutable dotfilesDir config;
  cfg = config.modules.public.agent;
in
{
  config = lib.mkIf cfg.enable {
    # Merge into one home.file attrset to satisfy statix W20 (repeated_keys).
    home.file.".pi/agent/extensions".source = mkMutable ./extensions;
    home.file.".pi/agent/themes".source = mkMutable ./themes;
    home.file.".pi/agent/prompts".source = mkMutable ./prompts;
  };
}
