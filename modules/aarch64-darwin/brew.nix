{
  config,
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
      # 只承载原始写法（字符串或普通 attrset），归一化交给 nix-darwin 的
      # homebrew.casks 自己做。不能继承它的 submodule 类型：其求值结果
      # 带有 readOnly 的派生字段 brewfileLine，一旦 homebrew.casks 出现
      # 第二个定义并按位置合并，该字段会被重复定义而报错。
      type = with lib.types; listOf (either str (attrsOf anything));
      default = [ ];
      # nix 模块系统中只有最高优先级的定义参与合并（lib/modules.nix
      # mergeDefinitions），同优先级的 list 定义才会拼接。因此默认值
      # 不在 default 里声明，而是在 config 中以普通优先级注入，
      # 让 rime 模块和各 host 的追加定义能与之拼接；
      # 需要整体替换时使用 lib.mkForce。
      description = "Homebrew casks to install, additively merged across modules and hosts.";
    };
  };

  config = {
    # 基础 cask 列表，以普通优先级注入（见上方 options 注释）
    modules.darwin.brew.casks = [
      # keep-sorted start
      # proxy client
      "clash-verge-rev"
      # opensource lightweight text-editor
      "coteditor"
      # keep-sorted end
    ];

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
      brews = [
        "container"
        "m-cli"
      ];
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
