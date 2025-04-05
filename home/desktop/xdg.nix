{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    xdg-utils
    xdg-user-dirs
  ];

  xdg.configFile."mimeapps.list".force = true;
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        XDG_DEV_DIR = "${config.home.homeDirectory}/Dev";
        XDG_WALLPAPERS_DIR = "${config.xdg.userDirs.pictures}/Wallpapers";
      };
    };
    mimeApps = let
      webBrowser = ["chromium"];

      xdgAssociations = type: program: list:
        builtins.listToAttrs (
          map (e: {
            name = "${type}/${e}";
            value = program;
          })
          list
        );
      browser =
        (xdgAssociations "application" webBrowser [
          "pdf"
          "json"
          "x-extension-htm"
          "x-extension-html"
          "x-extension-shtml"
          "x-extension-xht"
          "x-extension-xhtml"
        ])
        // (xdgAssociations "x-scheme-handler" webBrowser [
          "about"
          "ftp"
          "http"
          "https"
          "unknown"
        ]);

      # XDG MIME types
      associations = builtins.mapAttrs (_: v: (map (e: "${e}.desktop") v)) (
        {
          "text/html" = webBrowser;
          "text/plain" = ["codium"];
          "inode/directory" = ["thunar"];
        }
        // browser
      );
    in {
      enable = true;
      defaultApplications = associations;
    };
  };
}
