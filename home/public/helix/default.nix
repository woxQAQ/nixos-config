{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.public.helix;
in
{
  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
      settings = {
        editor = {
          line-number = "relative";
          cursorline = true;
          color-modes = true;
          lsp.display-messages = true;
          lsp.display-inlay-hints = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides.render = true;
          bufferline = "always";
        };
      };
      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
          language-servers = [ "nixd" ];
        }
        {
          name = "python";
          language-servers = [ "ty" ];
        }
      ];
    };

    home.packages = with pkgs; [
      ty
      nixfmt
      nixd
    ];
  };
}
