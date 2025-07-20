{
  programs = {
    fzf = {
      enable = true;
    };
    tealdeer = {
      enable = true;
      enableAutoUpdates = true;
      settings = {
        display = {
          compact = false;
          use_pager = true;
        };
        updates = {
          auto_update = false;
          auto_update_interval_hours = 720;
        };
      };
    };
    tmux = {
      enable = true;
    };
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
    btop = {
      enable = true;
      settings = {
        theme_background = false; # make btop transparent
      };
    };
    jq.enable = true;
    eza = {
      enable = true;
      enableNushellIntegration = true;
      git = true;
      icons = "auto";
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
