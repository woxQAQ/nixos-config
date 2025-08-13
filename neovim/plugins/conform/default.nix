{ lib, pkgs, ... }:
{
  conform-nvim = {
    enable = true;
    settings = {
      default_format_opts.lsp_format = "prefer";
      formatters_by_ft = {
        nix = [ "nixfmt" ];
        rust = [ "rustfmt" ];
        lua = [ "stylua" ];
        python = [
          "isort"
          "ruff"
        ];
      };
      formatters = {
        nixfmt = lib.getExe pkgs.nixfmt-rfc-style;
        rustfmt = lib.getExe pkgs.rustfmt;
        stylua = lib.getExe pkgs.stylua;
        isort = lib.getExe pkgs.isort;
        ruff = lib.getExe pkgs.ruff;
      };
      notify_on_error = false;
    };
  };
}
