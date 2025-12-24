return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      go = { "goimports", "gofumpt" },
    },
    formatters = {
      golines = {
        args = { "-m", "120" },
      },
    },
  },
}
