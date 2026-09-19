{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.public.playwright;
  # chromium plus headless shell and ffmpeg covers scraping; firefox/webkit
  # can be enabled by overriding playwright-driver.selectBrowsers
  browsers = pkgs.playwright-driver.selectBrowsers {
    withFirefox = false;
    withWebkit = false;
  };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.playwright-test ];
    home.sessionVariables = {
      # browsers downloaded by playwright itself cannot run on NixOS, so we
      # point playwright at the nix-built ones and skip its own downloads
      PLAYWRIGHT_BROWSERS_PATH = "${browsers}";
      PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    };
  };
}
