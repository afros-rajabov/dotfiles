return {
  'folke/noice.nvim',
  opts = {
    cmdline = {
      view = "cmdline",
      format = {
        -- cmdline = { pattern = "^:", icon = ">", lang = "vim" },
        lua = {
          pattern = { "^:%s*python%s+", "^:%s*python%s*=%s*", "^:%s*=%s*" },
          icon = "",
          lang = "python",
        },
      }
    }
  }
}
