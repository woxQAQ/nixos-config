{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = ":Neotree action=focus reveal toggle<CR>";
        options.silent = true;
      }
    ];

    plugins.neo-tree = {
      enable = true;
      sources = [
        "filesystem"
        "buffers"
        "git_status"
        "document_symbols"
      ];
      addBlankLineAtTop = false;

      closeIfLastWindow = true;
      window = {
        width = 30;
        autoExpandWidth = true;
      };
      filesystem = {
        bindToCwd = false;
        followCurrentFile = {
          enabled = true;
        };
        filteredItems = {
          hideDotfiles = false;
        };
      };
    };
  };
}
