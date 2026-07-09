{
  plugins.nvim-lightbulb = {
    enable = true;

    lazyLoad.settings.event = "DeferredUIEnter";

    settings = {
      autocmd = {
        enabled = true;
        updatetime = -1;
      };
      # line = {
      #   enabled = false;
      # };
      # number = {
      #   enabled = false;
      # };
      # sign = {
      #   enabled = true;
      #   text = " 󰌶";
      # };
      # status_text = {
      #   enabled = true;
      #   text = " 󰌶 ";
      # };
    };
  };
}
