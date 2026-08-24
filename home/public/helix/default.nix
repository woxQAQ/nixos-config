{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.public.helix;

  jsonMacroInjection = # query
    ''
      ((macro_invocation
         macro:
           [
             (scoped_identifier name: (_) @_macro_name)
             (identifier) @_macro_name
           ]
         (token_tree
           (token_tree . "{" "}" .) @injection.content))
       (#eq? @_macro_name "json")
       (#set! injection.language "json")
       (#set! injection.include-children))
    '';

  rustInjections = builtins.readFile "${pkgs.helix.runtime}/queries/rust/injections.scm";
  rustInjectionsWithoutJson =
    assert lib.assertMsg (lib.hasInfix jsonMacroInjection rustInjections)
      "Helix's Rust JSON macro injection query changed; update home/public/helix/default.nix";
    lib.replaceStrings [ jsonMacroInjection ] [ "" ] rustInjections;
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
          default-yank-register = "+";
          completion-timeout = 50;
          completion-trigger-len = 1;
          lsp.display-messages = true;
          lsp.display-inlay-hints = false;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides.render = true;
          bufferline = "always";
        };
        keys.normal.space."w".r = ":reload";
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
          language-servers = [
            {
              name = "ty";
            }
          ];
        }
        {
          name = "rust";
          # config.check.command = "clippy";
        }
        {
          name = "typescript";
          language-servers = [
            {
              name = "typescript-language-server";
            }
          ];
        }
        {
          name = "nu";
        }
        {
          name = "toml";
          formatter.command = "${pkgs.taplo}/bin/taplo";
          formatter.args = [
            "format"
            "-"
          ];
          auto-format = true;
        }
      ];
    };

    # serde_json::json! accepts Rust expressions as values. Parsing the entire
    # macro body as JSON leaves everything after the first expression in an
    # ERROR node and highlights otherwise identical object keys differently.
    xdg.configFile."helix/runtime/queries/rust/injections.scm".text = rustInjectionsWithoutJson;

    home.packages = with pkgs; [
      ty
      rust-analyzer
      clippy
      taplo
      nixfmt
      nixd
    ];
  };
}
