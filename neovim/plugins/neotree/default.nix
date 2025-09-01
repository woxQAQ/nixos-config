{
  neo-tree = {
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
        visible = true;
        hideDotfiles = false;
        hideGitignored = false;
      };
    };
  };
}
