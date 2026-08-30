{
  config,
  pkgs,
  lib,
  unstable-pkg,
  ...
}:
let
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
  environment = {
    systemPackages = with pkgs; [
      # aerospace
      bitwarden-desktop
      cc-switch
      git
      gnugrep
      koodo-reader
      mole-cleaner
      obsidian
      stats
      trufflehog
      vscode
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
    brews = [
      # "hey"
      # "podman"
      # "podman-compose"
    ];
    # masApps = {
    #   Wechat = 836500024;
    #   QQ = 451108668;
    #   TecentMeeting = 1484048379;
    # };
    casks = [
      # keep-sorted start

      # menubar enhanced
      # FIXME: ice broken on MacOS 26, drop it temporary
      # "jordanbaird-ice"

      # proxy client
      "clash-verge-rev"
      # opensource lightweight text-editor
      "coteditor"
      # cursor AI IDE
      # "cursor"
      # "dbeaver-community"
      # a easy-to-use translation dictionary
      # "easydict"
      "feishu"
      # opensource rss reader powered by rsshub
      # "folo"
      # a gba emulators to play gba games
      "mgba-app"
      # "neteasemusic"
      # Notion APP
      # "notion"
      # Open broadcast studio
      "obs"
      # "altserver"
      # browser
      # "arc"
      # baidu netdisk
      # "baidunetdisk"
      # chatgpt desktop app
      # "chatgpt"
      "raycast"
      # "pot"
      # input method
      "squirrel-app"
      # a signing daemon for my IOS apps which not supported by app-store
      # "iina"
      # "steam"
      # open source MacOS disk cleaner
      # "tencent-lemon"
      # AI IDE by Bytedance
      # "trae"
      # keep-sorted end
    ];
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
}
