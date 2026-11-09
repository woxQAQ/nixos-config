let
  shellAliases = {
    "zj" = "zellij";
  };
in
{
  programs.zellij = {
    enable = true;
    extraConfig = builtins.readFile ./zj-config.kdl;
  };
  home.shellAliases = shellAliases;
  programs.nushell.shellAliases = shellAliases;
}
