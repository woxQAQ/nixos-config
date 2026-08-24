{
  config,
  mylib,
  dotfilesDir,
  ...
}:
{
  home.file.".codex/AGENTS.md".source = mylib.mkMutable dotfilesDir config ./codex/AGENTS.md;
}
