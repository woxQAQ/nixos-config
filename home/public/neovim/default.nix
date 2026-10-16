{
  config,
  lib,
  nixvim,
  pkgs,
  mylib,
  dotfilesDir,
  ...
}:
let
  cfg = config.modules.public.neovim;

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

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };

    home.packages = with pkgs; [ dwt1-shell-color-scripts ];

    programs.nixvim = {
      # The nixvim submodule runs its own module evaluation and cannot see the
      # flake-level extraSpecialArgs (mylib, dotfilesDir), so forward the
      # derived values it needs explicitly, like mkKeymap above.
      _module.args = {
        inherit mkKeymap;
        nixdSettings = mylib.mkNixdSettings dotfilesDir;
      };
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
  };
}
