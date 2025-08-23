{ lib, pkgs, ... }:
{
  conform-nvim = {
    enable = true;
    settings = {
      default_format_opts.lsp_format = "fallback";
      formatters_by_ft = {
        nix = [ "nixfmt" ];
        python = [
          "isort"
          "ruff"
        ];
        "_" = [
          "squeeze_blanks"
          "trim_whitespace"
          "trim_newlines"
        ];
      };
    };
  };
}
