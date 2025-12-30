return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        -- GOLANG
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },

        -- PYTHON
        pylsp = {
          enabled = false,
          mason = false,
          settings = {
            pylsp = {
              plugins = {
                rope_autoimport = {
                  enabled = true,
                  memory = false,
                },
                preload = {
                  enabled = false,
                },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                mccabe = { enabled = false },
                pylsp_mypy = { enabled = false },
                pylsp_black = { enabled = false },
                pylsp_isort = { enabled = false },
              },
            },
          },
        },
        ruff = { enabled = true, mason = false },
        ruff_lsp = { enabled = false },
        pyright = {
          enabled = false,
        },
        marksman = { enabled = false, autostart = false },
        basedpyright = {
          mason = true,
          enabled = true,
        },

        -- RUST
        bacon_ls = {
          enabled = true,
        },
        rust_analyzer = { enabled = false },

        -- SQL
        sqlc = {
          enabled = true,
        },
      },
      setup = {
        gopls = function(_, opts)
          -- workaround for gopls not supporting semanticTokensProvider
          -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
          Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
            if not client.server_capabilities.semanticTokensProvider then
              local semantic = client.config.capabilities.textDocument.semanticTokens
              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
          end)
          -- end workaround
        end,
      },
    },
    keys = {
      -- {
      --   "gp",
      --   function()
      --     require("snacks.picker").lsp_definitions({
      --       auto_confirm = false,
      --     })
      --   end,
      --   desc = "Preview Definition",
      -- },
      {
        "<leader>co",
        "<cmd>lua vim.lsp.buf.code_action({ context = { only = 'source.organizeImports' } })<cr>",
        desc = "Organize Imports",
      },
    },
  },
}
