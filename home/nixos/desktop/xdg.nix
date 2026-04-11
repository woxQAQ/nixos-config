{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
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
    mimeApps = {
      enable = true;
      defaultApplications =
        let
          browser =
            if osConfig.modules.desktop.browser == "zen" then
              [ "zen-beta.desktop" ]
            else if osConfig.modules.desktop.browser == "firefox" then
              [ "firefox.desktop" ]
            else
              [
                "chromium-browser.desktop"
                "google-chrome.desktop"
              ];
          archiveManager = [ "org.gnome.FileRoller.desktop" ];
          archiveMimeTypes = [
            "application/zip"
            "application/x-zip"
            "application/x-zip-compressed"
            "application/x-7z-compressed"
            "application/vnd.rar"
            "application/x-rar"
            "application/x-rar-compressed"
            "application/x-tar"
            "application/x-compressed-tar"
            "application/x-bzip-compressed-tar"
            "application/x-xz-compressed-tar"
            "application/x-zstd-compressed-tar"
            "application/gzip"
            "application/x-gzip"
            "application/x-bzip"
            "application/x-bzip2"
            "application/x-xz"
            "application/zstd"
            "application/x-archive"
            "application/x-cpio"
          ];
          editor = [
            "nvim.desktop"
            "code.desktop"
            "code-insider.desktop"
          ];
        in
        {
          "application/json" = browser;
          "application/pdf" = browser;
          "text/html" = browser;
          "text/xml" = browser;
          "text/plain" = editor;
          "application/xml" = browser;
          "application/xhtml+xml" = browser;
          "application/xhtml_xml" = browser;
          "application/rdf+xml" = browser;
          "application/rss+xml" = browser;
          "application/x-extension-htm" = browser;
          "application/x-extension-html" = browser;
          "application/x-extension-shtml" = browser;
          "application/x-extension-xht" = browser;
          "application/x-extension-xhtml" = browser;
          "application/x-wine-extension-ini" = editor;

          # define default applications for some url schemes.
          "x-scheme-handler/about" = browser; # open `about:` url with `browser`
          "x-scheme-handler/ftp" = browser; # open `ftp:` url with `browser`
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          # https://github.com/microsoft/vscode/issues/146408
          "x-scheme-handler/vscode" = [ "code-url-handler.desktop" ]; # open `vscode://` url with `code-url-handler.desktop`
          "x-scheme-handler/vscode-insiders" = [ "code-insiders-url-handler.desktop" ]; # open `vscode-insiders://` url with `code-insiders-url-handler.desktop`
          "x-scheme-handler/zoommtg" = [ "Zoom.desktop" ];

          # all other unknown schemes will be opened by this default application.
          # "x-scheme-handler/unknown" = editor;

          "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop " ];

          "audio/*" = [ "mpv.desktop" ];
          "video/*" = [ "mpv.desktop" ];
          "image/*" = [ "imv-dir.desktop" ];
          "image/gif" = [ "imv-dir.desktop" ];
          "image/jpeg" = [ "imv-dir.desktop" ];
          "image/png" = [ "imv-dir.desktop" ];
          "image/webp" = [ "imv-dir.desktop" ];

          "inode/directory" = [ "yazi.desktop" ];
        }
        // lib.genAttrs archiveMimeTypes (_: archiveManager);
    };
  };
}
