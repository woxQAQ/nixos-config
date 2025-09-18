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
    masApps = {
      Wechat = 836500024;
      QQ = 451108668;
      TecentMeeting = 1484048379;
    };
    casks = [
      # keep-sorted start
      "aerospace"
      "altserver"
      "arc"
      "baidunetdisk"
      "bitwarden"
      # "clash-party"
      "clash-verge-rev"
      # "maccy"
      "coteditor"
      "cursor"
      "easydict"
      "feishu"
      "folo"
      "jordanbaird-ice"
      "koodo-reader"
      "mgba"
      "neteasemusic"
      # "stats"
      "notion"
      "obs"
      "obsidian"
      "raycast"
      "squirrel-app"
      # "iina"
      "steam"
      "tencent-lemon"
      "trae"
      # keep-sorted end
    ];
  };
}
