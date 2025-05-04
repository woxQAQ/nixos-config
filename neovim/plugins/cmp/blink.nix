{
  blink-ripgrep.enable = true;
  blink-emoji.enable = true;
  blink-cmp = {
    enable = true;
    settings = {
      appearance = {
        nerd_font_variant = "mono";
        kind_icons = {
          Class = "󱡠";
          Color = "󰏘";
          Constant = "󰏿";
          Constructor = "󰒓";
          Enum = "󰦨";
          EnumMember = "󰦨";
          Event = "󱐋";
          Field = "󰜢";
          File = "󰈔";
          Folder = "󰉋";
          Function = "󰊕";
          Interface = "󱡠";
          Keyword = "󰻾";
          Method = "󰊕";
          Module = "󰅩";
          Operator = "󰪚";
          Property = "󰖷";
          Reference = "󰬲";
          Snippet = "󱄽";
          Struct = "󱡠";
          Text = "󰉿";
          TypeParameter = "󰬛";
          Unit = "󰪚";
          Value = "󰦨";
          Variable = "󰆦";
        };
      };
      completion = {
        accept = {
          auto_brackets = {
            enabled = true;
            semantic_token_resolution = {
              enabled = false;
            };
          };
        };
        documentation = {
          auto_show = true;
          window.border = "rounded";
        };
        menu.border = "rounded";
      };
      keymap = {
        preset = "super-tab";
      };
      signature = {
        enabled = true;
      };
      sources = {
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
          "ripgrep"
          "emoji"
        ];
        cmdline = [];
        providers = {
          lsp = {
            score_offset = 4;
          };
          emoji = {
            module = "blink-emoji";
            name = "Emoji";
            score_offset = 1;
            # Optional configurations
            opts = {
              insert = true;
            };
          };
          ripgrep = {
            async = true;
            module = "blink-ripgrep";
            name = "Ripgrep";
            score_offset = 1;
            opts = {
              prefix_min_len = 3;
              context_size = 5;
              max_filesize = "1M";
              project_root_marker = ".git";
              project_root_fallback = true;
              search_casing = "--ignore-case";
              additional_rg_options = {};
              fallback_to_regex_highlighting = true;
              ignore_paths = {};
              additional_paths = {};
              debug = false;
            };
          };
        };
      };
    };
  };
}
