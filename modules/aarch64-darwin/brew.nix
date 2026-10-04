{
  config,
  options,
  pkgs,
  lib,
  unstable-pkg,
  ...
}:
let
  cfg = config.modules.darwin.brew;
  homebrew_env = {
    HOMEBREW_API_DOMAIN = "https://mirror.nju.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirror.nju.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirror.nju.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CLEANUP_MAX_AGE_DAYS = "7";
    HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS = "7";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirror.nju.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };
in
{
  options.modules.darwin.brew = {
    casks = lib.mkOption {
      # 与 nix-darwin 的 homebrew.casks 保持同一类型，允许字符串或带 caskArgs 的 attrset
      inherit (options.homebrew.casks) type;
      default = [
        # keep-sorted start
        # proxy client
        "clash-verge-rev"
        # opensource lightweight text-editor
        "coteditor"
        "feishu"
        # a gba emulators to play gba games
        "mgba-app"
        # Open broadcast studio
        "obs"
        "raycast"
        # input method
        "squirrel-app"
        # keep-sorted end
      ];
      description = "Homebrew casks to install, overridable per host.";
    };
  };

  config = {
    environment = {
      systemPackages = with pkgs; [
        git
        gnugrep
      ];
      shells = [
        pkgs.zsh
        unstable-pkg.nushell
      ];
      variables = homebrew_env // {
        PATH = "/opt/homebrew/bin:/usr/local/texlive/2025/bin/universal-darwin:$PATH";
      };
    };
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "zap";
        extraEnv = homebrew_env;
      };
      global = {
        autoUpdate = true;
        brewfile = true;
      };
      taps = [ ];
      brews = [ ];
      inherit (cfg) casks;
    };
    system.activationScripts.homebrew.text = lib.mkIf config.homebrew.enable (
      lib.mkAfter ''
        echo >&2 "Homebrew cleanup..."
        if [ -f "${config.homebrew.prefix}/bin/brew" ]; then
          PATH="${config.homebrew.prefix}/bin:$PATH" \
          sudo \
            --preserve-env=PATH \
            --user=${lib.escapeShellArg config.system.primaryUser} \
            --set-home \
            env \
            HOMEBREW_CLEANUP_MAX_AGE_DAYS=7 \
            HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=7 \
            brew cleanup --prune=7
        else
          echo -e "\e[1;31merror: Homebrew is not installed, skipping cleanup...\e[0m" >&2
        fi
      ''
    );
  };
}
