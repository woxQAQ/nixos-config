{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.public.desktop;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # declare font packages to avoid font missing
      ioskeley-mono.term-nf
      inter-noto-sans-sc
      chillroundf

      nixd
      oxfmt
      pyright
    ];
    programs.zed-editor = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.zed-editor-bin else pkgs.zed-editor;
      mutableUserSettings = false;
      extensions = [
        # keep-sorted start
        "catppuccin"
        "catppuccin-icons"
        "colored-zed-icons-theme"
        "csharp"
        "dockerfile"
        "git-firefly"
        "go-snippets"
        "helm"
        "html"
        "java"
        "just"
        "lua"
        "make"
        "material-icon-theme"
        "nix"
        "nu"
        "prisma"
        "proto"
        "rust-snippets"
        "scheme"
        "sql"
        "svelte"
        "svelte-snippets"
        "terraform"
        "toml"
        "vscode-dark-modern"
        "vscode-icons"
        "vue"
        "xml"
        # keep-sorted end
      ];
      userSettings = {
        context_servers = { };
        markdown_preview = {
          font_family = "ChillRoundF";
        };
        # Nix manages updates; the app bundle in the store is read-only.
        auto_update = false;
        diff_view_style = "unified";
        diagnostics = {
          inline = {
            enabled = false;
          };
        };
        outline_panel = {
          dock = "right";
        };
        collaboration_panel = {
          dock = "right";
        };
        project_panel = {
          dock = "right";
          hide_hidden = false;
          hide_root = false;
          entry_spacing = "comfortable";
          auto_fold_dirs = false;
          button = true;
          git_status = true;
        };
        agent_servers = {
          codex-acp = {
            default_config_options = {
              mode = "agent-full-access";
              reasoning_effort = "xhigh";
            };
            type = "registry";
          };
          pi-acp = {
            default_config_options = {
              thought_level = "high";
              model = "kimi-coding/k3";
            };
            type = "registry";
          };
          kimi = {
            type = "registry";
          };
        };
        inlay_hints = {
          enabled = false;
          show_type_hints = true;
        };
        indent_guides = {
          enabled = true;
          coloring = "indent_aware";
        };
        current_line_highlight = "all";
        text_rendering_mode = "platform_default";
        ui_font_family = "Inter Noto Sans SC";
        terminal = {
          toolbar = {
            breadcrumbs = false;
          };
          font_size = 15;
          shell = {
            program = "nu";
          };
          env = {
            EDITOR = "zed --wait";
          };
        };
        file_types = {
          Dockerfile = [
            "Dockerfile"
            "Dockerfile.*"
          ];
          JSON = [
            "json"
            "jsonc"
          ];
        };
        git_panel = {
          tree_view = false;
          dock = "right";
        };
        git = {
          inline_blame = {
            enabled = true;
          };
        };
        session = {
          trust_all_worktrees = true;
        };
        status_bar = { };
        gutter = {
          line_numbers = true;
        };
        cursor_shape = "bar";
        cursor_blink = false;
        use_system_window_tabs = true;
        show_whitespaces = "all";
        hard_tabs = true;
        relative_line_numbers = "enabled";
        tab_bar = {
          show = true;
        };
        scrollbar = { };
        tabs = {
          show_diagnostics = "errors";
        };
        which_key = {
          enabled = true;
        };
        centered_layout = {
          left_padding = 0.15;
          right_padding = 0.15;
        };
        buffer_line_height = "comfortable";
        agent = {
          dock = "left";
        };
        icon_theme = "Material Icon Theme";
        vim_mode = true;
        ui_font_size = 16;
        buffer_font_family = "IoskeleyMonoTerm Nerd Font Mono";
        buffer_font_size = 14;
        file_finder = {
          modal_max_width = "medium";
        };
        theme = {
          mode = "system";
          light = "Catppuccin Latte";
          dark = "Catppuccin Macchiato";
        };
        format_on_save = "off";
        languages = {
          Nix = {
            language_servers = [
              "nixd"
              "!nil"
            ];
          };
          Markdown = {
            formatter = {
              external = {
                command = "oxfmt";
              };
            };
          };
          Rust = {
            inlay_hints = {
              enabled = true;
            };
          };
          Python = {
            language_servers = [
              "pyright"
            ];
            inlay_hints = {
              enabled = true;
            };
          };
          Go = {
            formatter = "language_server";
          };
        };
        lsp = {
          nixd = {
            settings = {
              diagnostic = {
                suppress = [
                  "sema-extra-with"
                ];
              };
            };
          };
        };
        telemetry = {
          diagnostics = true;
          metrics = false;
        };
      };
    };
  };
}
