{
  plugins.colorful-menu = {
    enable = true;
    settings = {
      ls = {
        gopls = {
          align_type_to_right = true;
          add_colon_before_type = false;
          preserve_type_when_truncate = true;
        };
        ts_ls = {
          extra_info_hl = "@comment";
        };
        rust-analyzer = {
          extra_info_hl = "@comment";
          align_type_to_right = true;
          preserve_type_when_truncate = true;
        };
        fallback = true;
        fallback_extra_info_hl = "@comment";
      };
      fallback_highlight = "@variable";
      max_width = 60;
    };
  };
}
