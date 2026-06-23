{
  plugins.quicker = {
    enable = true;
    settings = {
      max_filename_width.__raw = ''
        function()
          return math.floor(math.min(40, vim.o.columns / 2))
        end
      '';
    };
  };
}
