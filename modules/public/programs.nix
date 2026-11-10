{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.modules.public.helix.enable =
    lib.mkEnableOption "system-wide Helix"
    // {
      default = true;
    };

  config = {
    environment.variables = {
      EDITOR = if config.modules.public.helix.enable then "hx" else "nvim";
      VISUAL = if config.modules.public.helix.enable then "hx" else "nvim";
      SUDO_EDITOR = "nvim --clean";
    };
    environment.systemPackages =
      with pkgs;
      [
        nushell
        neovim

        age
        yq
        tealdeer
        tokei
      ]
      ++ lib.optional config.modules.public.helix.enable helix;
  };
}
