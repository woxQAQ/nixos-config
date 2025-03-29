{
  programs.nixvim.plugins = {
    which-key = {
      enable = true;
      settings = {
        delay = 200;
        expand = 1;
        notify = false;
        preset = false;
      };
    };
  };
}
