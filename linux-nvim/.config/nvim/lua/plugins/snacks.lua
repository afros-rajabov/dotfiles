return {
  "folke/snacks.nvim",
  keys = {
    {
      "gp",
      function()
        Snacks.picker.lsp_definitions({ auto_confirm = false })
      end,
      desc = "Preview Definition",
    },
    {
      "<leader>zd",
      function()
        local noice = require("noice")
        noice.disable()
        local snacks = require("snacks")
        snacks.config.zen.toggles.dim = not snacks.config.zen.toggles.dim
        snacks.toggle.zen():toggle()
        snacks.toggle.zen():toggle()
        noice.enable()
      end,
      desc = "Toggle Zen Dim",
    },
  },
  opts = {
    explorer = {
      enabled = false,
    },
    zen = {
      toggles = {
        dim = false,
      },
      show = {
        statusline = true, -- can only be shown when using the global statusline
      },
      win = {
        minimal = false,
        backdrop = { transparent = false },
      },
    },
    terminal = {
      win = {
        position = "float",
      },
    },
    picker = {
      sources = {
        files = {
          ignored = true,
          hidden = true,
          exclude = {
            ".git",
            ".venv",
            "venv",
            ".idea",
            ".ruff_cache",
            "__pycache__",
          },
        },
        explorer = {
          enabled = false,
          ignored = true,
          hidden = true,
          exclude = {
            ".git",
            ".idea",
            ".ruff_cache",
            "__pycache__",
          },
        },
      },
    },
  },
}
