let
  shellAliases = {
    "zj" = "zellij";
  };
in
{
  programs.zellij = {
    enable = true;
  };
  xdg.configFile."zellij/config.kdl".source = ./zj-config.kdl;
  home.shellAliases = shellAliases;
  programs.nushell.shellAliases = shellAliases;
}
