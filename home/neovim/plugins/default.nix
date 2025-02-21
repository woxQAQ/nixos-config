{
  imports = [
    ./comments.nix
    ./cmp.nix
    ./term.nix
    ./lsp
    ./lint.nix
    ./lualine.nix
    ./neotree.nix
    ./dashboard.nix
    ./telescope.nix
    ./helm.nix
    ./barbar
    ./git
    ./cmp
    ./chat
    ./which-key.nix
    ./projects.nix
    ./treesitter.nix
  ];

  programs.nixvim = {

    plugins = {
      web-devicons.enable = true;
      nvim-autopairs.enable = true;
      colorizer = {
        enable = true;
        settings.user_default_options.names = false;
      };
      nui.enable = true;
      noice.enable = true;
      oil.enable = true;
      notify.enable = true;
      illuminate = {
        enable = true;
        underCursor = true;
        filetypesDenylist = [
          "Outline"
          "TelescopePrompt"
          "reason"
        ];
      };
      trim = {
        enable = true;
        settings = {
          highlight = true;
          ft_blocklist = [
            "checkhealth"
            "floaterm"
            "lspinfo"
            "neo-tree"
            "TelescopePrompt"
          ];
        };
      };
    };
  };
}
