{
  plugins.illuminate = {
    enable = true;
    settings = {
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
      min_count_to_highlight = 2;
    };
  };
}
