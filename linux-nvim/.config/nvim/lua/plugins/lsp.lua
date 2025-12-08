return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- ts_ls = {},
        -- ruff = {},
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
      },
    },
    keys = {
      {
        "gp",
        function()
          require("snacks.picker").lsp_definitions({
            auto_confirm = false,
          })
        end,
        desc = "Preview Definition",
      },
      {
        "<leader>co",
        "<cmd>lua vim.lsp.buf.code_action({ context = { only = 'source.organizeImports' } })<cr>",
        desc = "Organize Imports",
      },
    },
  },
}
