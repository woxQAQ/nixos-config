{
  pkgs,
  llm-agents,
  config,
  mylib,
  dotfilesDir,
  ...
}:
{
  home.packages = with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    fx
  ];

  home.file.".fx/settings.json".source = mylib.mkMutable dotfilesDir config ./fx-settings.json;
}
