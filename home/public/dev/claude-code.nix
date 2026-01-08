{
  claude-code-pkg,

  ...
}:
{
  home.packages = with claude-code-pkg; [
    claude-code
  ];
  home.file.".claude/settings.json" = {
    source = ./claude-code.settings.json;
  };
}
