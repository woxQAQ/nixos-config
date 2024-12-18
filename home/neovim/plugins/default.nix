{
  imports = [
    ./comments.nix
    ./term.nix
    ./lsp
    ./lualine.nix
    ./neotree.nix
    ./dashboard.nix
    ./telescope.nix
    ./helm.nix
    ./barbar
    ./git
    ./chat
    ./which-key.nix
    ./projects.nix
    ./treesitter.nix
  ];

  programs.nixvim = {
    colorschemes.gruvbox.enable = true;

    plugins = {
      web-devicons.enable = true;
      nvim-autopairs.enable = true;
      colorizer = {
        enable = true;
        settings.user_default_options.names = false;
      };

      oil.enable = true;

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
