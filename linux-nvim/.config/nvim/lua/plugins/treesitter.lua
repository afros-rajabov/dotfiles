return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, {
      -- Golang
      "go",
      "gomod",
      "gowork",
      "gosum",
      -- Rust
      "rust",
      "ron",
    })
  end,
}
