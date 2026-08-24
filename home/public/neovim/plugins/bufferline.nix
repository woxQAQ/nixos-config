{ mkKeymap, ... }:
{
  plugins.bufferline = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    settings.options = {
      diagnostics = "nvim_lsp";
      mode = "buffers";
      numbers = "none";
      close_command = "bdelete! %d";
      indicator = {
        icon = "▎";
        style = "icon";
      };

      show_buffer_icons = false;
      show_buffer_close_icons = true;
      show_close_icon = true;
      show_tab_indicators = true;
      separator_style = "bar";
      enforce_regular_tabs = false;
      always_show_bufferline = true;
      sort_by = "id";
      max_name_length = 18;
      max_prefix_length = 15;
      tab_size = 10;
      # diagnostics = false;
      buffer_close_icon = "";
      modified_icon = "●";
      close_icon = "";
      left_trunc_marker = "";
      right_trunc_marker = "";
    };
  };
  keymaps = [
    (mkKeymap "n" "<leader>bp" "<cmd>BufferLinePick<cr>" "pick buffer")
  ];
}
