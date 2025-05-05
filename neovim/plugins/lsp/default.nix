{
  pkgs,
  scanPlugins,
  lib,
  ...
} @ args: let
  data = scanPlugins ./. args;
in
  lib.attrsets.mergeAttrsList [
    (lib.attrsets.mergeAttrsList data)
    {
      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
      };
      nix = {
        enable = true;
      };

      colorizer = {
        enable = true;
        settings.user_default_options.css = true;
      };

      ts-autotag = {
        enable = true;
      };

      lsp = {
        enable = true;
        inlayHints = true;
        keymaps = {
          silent = true;
          # diagnostic = {
          #   # Navigate in diagnostics
          #   "]e" = "goto_prev";
          #   "[e" = "goto_next";
          # };

          lspBuf = {
            # gd = "definition";
            gD = "references";
            # gt = "type_definition";
            # K = "hover";
            # "<F2>" = "rename";
          };

          extra = [
            {
              action = "<CMD>Lspsaga code_action<CR>";
              key = "<leader>ca";
              options.desc = "code action";
            }
            {
              action = "<CMD>Lspsaga rename<CR>";
              key = "<leader>cr";
              options.desc = "rename";
            }
            {
              action = "<CMD>Lspsaga finder<CR>";
              key = "gr";
              options.desc = "find references";
            }
            {
              action = "<CMD>Lspsaga finder imp<CR>";
              key = "gi";
              options.desc = "find implement";
            }
            {
              action = "<CMD>Lspsaga peek_definition<CR>";
              key = "gd";
              options.desc = "find definition";
            }
            {
              action = "<CMD>Lspsaga peek_type_definition<CR>";
              key = "gt";
              options.desc = "find type definition";
            }
            {
              action = "<CMD>Lspsaga hover_doc<CR>";
              key = "K";
              options.desc = "hover doc";
            }
          ];
        };
        servers = {
          clangd.enable = true;
          nil_ls = {
            enable = true;
            settings.formatting.command = [
              "alejandra"
            ];
          };
          pylsp.enable = true;
          pyright = {
            enable = true;
          };

          helm_ls = {
            enable = true;
            extraOptions = {
              settings = {
                "helm_ls" = {
                  yamlls = {
                    path = "${pkgs.yaml-language-server}/bin/yaml-language-server";
                  };
                };
              };
            };
          };

          ts_ls = {
            enable = true;
            settings.formatting.command = [
              "prettier"
            ];
          };
          cssls = {
            enable = true;
            filetypes = ["css" "scss" "less"];
          };
          protols.enable = true;
          html.enable = true;
          statix.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          jsonls.enable = true;
          gopls = {
            enable = true;
            autostart = true;
          };
          yamlls = {
            enable = true;
            extraOptions = {
              settings = {
                yaml = {
                  schemas = {
                    kubernetes = "'*.yaml";
                    "http://json.schemastore.org/github-workflow" = ".github/workflows/*";
                    "http://json.schemastore.org/github-action" = ".github/action.{yml,yaml}";
                    "http://json.schemastore.org/ansible-stable-2.9" = "roles/tasks/*.{yml,yaml}";
                    "http://json.schemastore.org/kustomization" = "kustomization.{yml,yaml}";
                    "http://json.schemastore.org/ansible-playbook" = "*play*.{yml,yaml}";
                    "http://json.schemastore.org/chart" = "Chart.{yml,yaml}";
                    "https://json.schemastore.org/dependabot-v2" = ".github/dependabot.{yml,yaml}";
                    "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" = "*docker-compose*.{yml,yaml}";
                    "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json" = "*flow*.{yml,yaml}";
                  };
                };
              };
            };
          };
        };
      };
    }
  ]
