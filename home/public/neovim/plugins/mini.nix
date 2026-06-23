{
  plugins = {
    mini-icons = {
      enable = true;
      mockDevIcons = true;
      luaConfig.pre = ''
        require("mini.icons").tweak_lsp_kind()
      '';
    };
  };
}
