{
  plugins.illuminate = {
    enable = true;
    settings = {
      # delay = 500;
      filetypes_allowlist = [
        "go"
        "rust"
        "javascript"
        "json"
        "lua"
        "python"
        "sh"
        "toml"
        "typescript"
        "yaml"
      ];
      # large_file_cutoff = 2000;
      # large_file_overrides = {
      #   providers = [ "lsp" ];
      # };
      min_count_to_highlight = 2;
      # providers = [
      #   "lsp"
      #   "regex"
      # ];
      # under_cursor = false;
    };
  };
}
