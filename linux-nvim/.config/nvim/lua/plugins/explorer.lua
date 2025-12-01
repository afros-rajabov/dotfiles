return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          ignored = true,
          hidden = true,
          include = {
            -- ".env",
          },
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
