{
  nu_scripts,
  pkgs,
  ...
}:
{
  home.packages = with pkgs.nushellPlugins; [
    query
  ];
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    extraConfig = # nu
      ''
        # completion
        source /etc/agenix/private.nu
        $env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
        $env.ENABLE_LSP_TOOL = true
        $env.ANTHROPIC_API_KEY = $env.ZAI_API_KEY_ALT
        $env.ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic"
        $env.KIMI_BASE_URL = "https://api.siliconflow.cn/v1"
        $env.KIMI_MODEL_NAME = "moonshotai/Kimi-K2-Thinking"

        const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${nu_scripts}']
        use custom-completions/git/git-completions.nu *
        use custom-completions/gh/gh-completions.nu *
        use custom-completions/tealdeer/tldr-completions.nu *
        use custom-completions/tar/tar-completions.nu *
        use custom-completions/zellij/zellij-completions.nu *
        use custom-completions/docker/docker-completions.nu *
        use custom-completions/uv/uv-completions.nu *
        use custom-completions/rg/rg-completions.nu *
        use custom-completions/pnpm/pnpm-completions.nu *
        use custom-completions/make/make-completions.nu *
        use custom-completions/npm/npm-completions.nu *
        use custom-completions/man/man-completions.nu *
        use custom-completions/nix/nix-completions.nu *
        use custom-completions/ssh/ssh-completions.nu *
        use custom-completions/cargo/cargo-completions.nu *
        use custom-completions/curl/curl-completions.nu *
        # alias
        use aliases/git/git-aliases.nu *
        use aliases/eza/eza-aliases.nu *
        use aliases/bat/bat-aliases.nu *

        use modules/argx *
        use modules/lg *
        use modules/kubernetes *
      '';
  };
}
