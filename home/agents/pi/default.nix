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
  home.file.".pi/agent/extensions".source = mkMutable ./extensions;
  home.file.".pi/agent/themes".source = mkMutable ./themes;
}
