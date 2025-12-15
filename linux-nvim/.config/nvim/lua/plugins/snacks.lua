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
  },
  opts = {
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
