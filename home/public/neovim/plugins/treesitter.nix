{ config, mkKeymap, ... }:
{
  plugins = {
    treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      folding.enable = true;
      grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
        # keep-sorted start
        bash
        go
        javascript
        json
        lua
        make
        markdown
        nix
        nu
        python
        regex
        rust
        toml
        typescript
        yaml
        # keep-sorted end
      ];
    };
    treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          enable = true;
          lookahead = true;
          selection_modes = {
            "@parameter.outer" = "v";
            "@function.outer" = "V";
            "@function.inner" = "V";
            "@class.inner" = "V";
            "@class.outer" = "V";
          };
          include_surrounding_whitespace = false;
        };
      };
    };
  };
  keymaps =
    let
      fun =
        select:
        ''require("nvim-treesitter-textobjects.select").select_textobject("${select}","textobjects")'';
    in
    [
      (mkKeymap [ "x" "o" ] "af" (fun "@function.outer"))
      (mkKeymap [ "x" "o" ] "if" (fun "@function.inner"))
      (mkKeymap [ "x" "o" ] "ac" (fun "@class.outer"))
      (mkKeymap [ "x" "o" ] "if" (fun "@class.inner"))
    ];
}
