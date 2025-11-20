{
  pkgs,
  unstable-pkg,
  ...
}:
let
  homebrew_env = {
    HOMEBREW_API_DOMAIN = "https://mirror.nju.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirror.nju.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirror.nju.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirror.nju.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };
in
{
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
    };
    taps = [
      "zackriya-solutions/meetily-backend"
      "nikitabobko/tap"
      "pot-app/homebrew-tap"
    ];
    brews = [
      # "meetily-backend"
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

      # NOTE: DROP to use MacOS 26 spotlight
      # "raycast"

      # menubar enhanced
      # FIXME: ice broken on MacOS 26, drop it temporary
      # "jordanbaird-ice"

      # a yabai alternative for macos
      "aerospace"
      # a signing daemon for my IOS apps which not supported by app-store
      "altserver"
      # browser
      "arc"
      # baidu netdisk
      "baidunetdisk"
      # password manager
      "bitwarden"
      # chatgpt desktop app
      "chatgpt"
      # proxy client
      "clash-verge-rev"
      # opensource lightweight text-editor
      "coteditor"
      # cursor AI IDE
      "cursor"
      # a easy-to-use translation dictionary
      "easydict"
      "feishu"
      # opensource rss reader powered by rsshub
      "folo"
      # e-book reader
      "koodo-reader"
      # a gba emulators to play gba games
      "mgba-app"
      # netease cloud music
      "neteasemusic"
      # Notion APP
      "notion"
      # Open broadcast studio
      "obs"
      # obsidian note
      "obsidian"
      # input method
      "squirrel-app"
      # menubar computer monitor
      "stats"
      # "iina"
      "steam"
      # open source MacOS disk cleaner
      "tencent-lemon"
      # AI IDE by Bytedance
      "trae"
      "visual-studio-code"
      # keep-sorted end
    ];
  };
}
