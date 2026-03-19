{ pkgs, ... }:
{
  # yazi, a blasting fast tui file manager
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    plugins = {
      inherit (pkgs.yaziPlugins) git;
    };
    initLua = # lua
      ''
        require("git"):setup {
          -- Order of status signs showing in the linemode
          order = 1500,
        }
      '';
    settings = {
      mgr = {
        show_hidden = true;
        sort_dir_first = true;
      };
      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            url = "*";
            run = "git";
          }
          {
            id = "git";
            url = "*/";
            run = "git";
          }
        ];
      };
    };
  };
}
