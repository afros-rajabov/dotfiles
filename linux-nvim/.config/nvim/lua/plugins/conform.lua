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
    format_on_save = {
      lsp_fallback = false,
      async = false,
      timeout_ms = 2000,
    },
  },
}
