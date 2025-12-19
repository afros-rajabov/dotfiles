return {
  "mikavilpas/yazi.nvim",
  version = "*", -- use the latest stable version
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "<leader>i",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      -- Open in the current working directory
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
    integrations = {
      grep_in_selected_files = function(selected_files)
        Snacks.notify("Grep in selected files", {
          level = "info",
        })
        if #selected_files > 0 then
          local dirs = {}
          local globs = {}
          for _, file in ipairs(selected_files) do
            local f = tostring(file)
            -- get dir name & filename
            local dir = vim.fn.fnamemodify(f, ":h")
            local filename = vim.fn.fnamemodify(f, ":t")
            dirs[dir] = true
            table.insert(globs, filename)
          end
          Snacks.picker.grep({
            dirs = vim.tbl_keys(dirs),
            glob = globs,
          })
          local keycode = vim.keycode("i")
          vim.api.nvim_feedkeys(keycode, "n", true)
        else
          Snacks.notify("No files selected", {
            level = "error",
          })
        end
      end,
      grep_in_directory = function(directory)
        Snacks.notify("Grep in " .. directory, {
          level = "info",
        })
        local dirs = { directory }
        Snacks.picker.grep({
          finder = "grep",
          dirs = dirs,
          ignored = true,
          hidden = true,
          focus = "input",
          live = true,
          supports_live = true,
        })
        local keycode = vim.keycode("i")
        vim.api.nvim_feedkeys(keycode, "n", true)
      end,
      picker_add_copy_relative_path_action = "snacks.nvim",
    },
  },
  -- 👇 if you use `open_for_directories=true`, this is recommended
  init = function()
    -- mark netrw as loaded so it's not loaded at all.
    --
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    vim.g.loaded_netrwPlugin = 1
  end,
}
