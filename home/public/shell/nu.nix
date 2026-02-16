{
  nu_scripts,
  pkgs,
  config,
  ...
}:
let
  vlogs_endpoint = "http://127.0.0.1:9428/insert/opentelemetry/v1/logs";
  vmmetrics_endpoint = "http://127.0.0.1:8428/opentelemetry/v1/metrics";
in
{
  home.packages = with pkgs.nushellPlugins; [
    query
  ];
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    extraConfig = # nu
      ''
        source /etc/agenix/private.nu
        let home = "${config.home.homeDirectory}";
        # claude code specific
        def init_files [] {
          let arr = [
            $'($home)/.claude.json'
            $'($home)/.claude/settings.json'
            $'($home)/.codex/config.toml'
          ]
          for $file in $arr {
            if not ($file | path exists) {
              touch $file
              if ($file | str ends-with "json") {
                {} | to json o> $file
              }
            }
          }
        }
        init_files
        open $'($home)/.claude.json' | merge {
          hasCompletedOnboarding: true,
          hasCompletedProjectOnboarding: true,
          hasTrustDialogAccepted: true,
          hasTrustDialogHooksAccepted: true,
          bypassPermissionsModeAccepted: true,
          shiftEnterKeyBindingInstalled: true,
          
        } | to json o> $'($home)/.claude.json'
        open $'($home)/.claude/settings.json' | merge {
          env: {
            CLAUDE_CODE_ENABLE_TELEMETRY: 1,
            OTEL_LOG_USER_PROMPTS: 1,
            OTEL_LOGS_EXPORTER: "otlp",
            OTEL_METRICS_EXPORTER: "otlp",
            OTEL_EXPORTER_OTLP_PROTOCOL: "http/protobuf",
            OTEL_EXPORTER_OTLP_METRICS_ENDPOINT: "${vmmetrics_endpoint}",
            OTEL_EXPORTER_OTLP_LOGS_ENDPOINT: "${vlogs_endpoint}",
            OTEL_RESOURCE_ATTRIBUTES: "job=claude",
            CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1",
            CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: "1",
            ENABLE_LSP_TOOL: true,
          }
          statusLine: {
            type: "command",
            command: "npx -y @owloops/claude-powerline@latest --style=powerline"
          }
        } | to json o> $'($home)/.claude/settings.json'

        # openAI otlp 
        open $'($home)/.codex/config.toml' | merge {
          otel: {
            log_user_prompt: true,
            exporter: {
              otlp-http: {
                endpoint: "${vlogs_endpoint}",
                protocol: "binary",
              },
            },
            trace-exporter: {
              otlp-http: {
                endpoint: "${vmmetrics_endpoint}"
                protocol: "binary"
              }
            }
          }
        } | to toml o> $'($home)/.codex/config.toml'


        $env.KIMI_MODEL_NAME = "kimi-for-coding"
        # Provider configurations
        let providers = {
          glm: {
            api_key: $env.ZAI_API_KEY_ALT,
            base_url: "https://open.bigmodel.cn/api/anthropic",
            model: "glm-5"
          },
          volcengine: {
            api_key: $env.ARK_CODE_API_KEY,
            base_url: "https://ark.cn-beijing.volces.com/api/coding",
            model: "ark-code-latest"
          },
          kimi: {
            api_key: $env.KIMI_API_KEY,
            base_url: "https://api.kimi.com/coding",
            model: $env.KIMI_MODEL_NAME
          }
        }

        # Function to switch AI provider for Claude Code
        def --env ai-switch [
          provider: string@"nu-complete ai-providers" # ai providers
          --no-output # not output switch messages
        ] {
          let cfg = $providers | get $provider

          $env.ANTHROPIC_API_KEY = $cfg.api_key
          $env.ANTHROPIC_BASE_URL = $cfg.base_url

          if ($cfg.model | is-not-empty) {
            $env.ANTHROPIC_MODEL = $cfg.model
          } else {
            $env.ANTHROPIC_MODEL = null
          }
          if not $no_output {
            print $"Switched to ($provider) provider:"
            print $"  ANTHROPIC_BASE_URL: ($env.ANTHROPIC_BASE_URL)"
            print $"  ANTHROPIC_MODEL: ($env.ANTHROPIC_MODEL | default '(not set)')"
          }
        }

        # Completion helper for available providers
        def "nu-complete ai-providers" [] {
          [glm, volcengine, kimi]
        }

        # Set default provider (kimi)
        ai-switch glm --no-output

        # completion
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
