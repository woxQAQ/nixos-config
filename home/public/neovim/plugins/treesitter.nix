{ config, ... }:
{
  filetype.pattern = {
    ".*/templates/.*%.tpl" = "helm";
    ".*/templates/.*%.txt" = "helm";
    ".*/templates/.*%.ya?ml" = "helm";
  };

  plugins = {
    treesitter = {
      enable = true;
      settings = {
        indent.enable = true;
        highlight.enable = true;
      };
      folding.enable = false;
      nixvimInjections = true;
      grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
        # keep-sorted start
        bash
        gitcommit
        gitignore
        go
        gomod
        gosum
        gotmpl
        gowork
        helm
        java
        javascript
        json
        just
        lua
        make
        markdown
        nix
        nu
        python
        rust
        sql
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
          keymaps = {
            "aa" = "@parameter.outer";
            "ia" = "@parameter.inner";
            "af" = "@function.outer";
            "if" = "@function.inner";
            "ac" = "@class.outer";
            "ic" = "@class.inner";
            "ii" = "@conditional.inner";
            "ai" = "@conditional.outer";
            "il" = "@loop.inner";
            "al" = "@loop.outer";
            "at" = "@comment.outer";
          };
          move = {
            enable = true;
            goto_next_start = {
              "]m" = "@function.outer";
              "]]" = "@class.outer";
            };
            goto_next_end = {
              "]M" = "@function.outer";
              "][" = "@class.outer";
            };
            goto_previous_start = {
              "[m" = "@function.outer";
              "[[" = "@class.outer";
            };
            goto_previous_end = {
              "[M" = "@function.outer";
              "[]" = "@class.outer";
            };
          };
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
}
