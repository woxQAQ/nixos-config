{
  plugins = {
    blink-cmp = {
      enable = true;
      lazyLoad.settings.event = [
        "InsertEnter"
        "CmdlineEnter"
      ];
      settings = {
        appearance.nerd_font_variant = "mono";
        sources = {
          default = [
            "lsp"
            "path"
            "buffer"
            "omni"
          ];
        };
        fuzzy.implementation = "prefer_rust_with_warning";
        cmdline = {
          completion = {
            menu = {
              auto_show = true;
            };
          };
          keymap = {
            "<Enter>" = [
              "select_and_accept"
              "fallback"
            ];
          };
        };
        keymap = {
          preset = "default";
          "<Tab>" = [
            "select_next"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "fallback"
          ];
          "<Enter>" = [
            "select_and_accept"
            "fallback"
          ];
          "<C-U>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-D>" = [
            "scroll_documentation_down"
            "fallback"
          ];
        };
      };
    };
    blink-pairs = {
      enable = true;
      lazyLoad.settings = {
        event = [
          "BufReadPost"
          "BufNewFile"
        ];
      };
    };
    blink-indent = {
      enable = true;
      lazyLoad.settings = {
        event = [
          "BufReadPost"
          "BufNewFile"
        ];
      };
    };
  };
}
