{
  nixvim,
  pkgs,
  ...
}:
let
  mkKeymap =
    mode: key: action:
    let
      withOptions = opt: {
        inherit mode key action;
        options = if builtins.isString opt then { desc = opt; } else opt;
      };
    in
    {
      # Nix has no optional positional arguments. Make the 3-arg result callable
      # for the 4-arg form, while letting nixvim ignore this internal attr.
      _module.check = false;
      inherit mode key action;
      __functor = _: withOptions;
    };
in
{
  imports = [ nixvim.homeModules.nixvim ];

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  programs.nixvim = {
    _module.args = { inherit mkKeymap; };
    nixpkgs.config.allowUnfree = true;
    nixpkgs.source = pkgs.path;
    imports = [
      ./keymaps.nix
      ./options.nix
      ./lsp.nix
      ./performance.nix
      ./plugins
      ./diagnostics.nix
    ];
    enable = true;
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        transparent_background = true;
      };
    };
    plugins.which-key = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };
  };
}
