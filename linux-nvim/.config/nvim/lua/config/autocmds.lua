-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable autoformat for python files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "python", "lua" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.diagnostic.enable(false) -- disable diagnostics for current buffer
  end,
})

-- NOTE: Center layout for mini-files

-- Window width based on the offset from the center, i.e. center window
-- is 60, then next over is 20, then the rest are 10.
-- Can use more resolution if you want like { 60, 20, 20, 10, 5 }
local widths = { 60, 20, 10 }

local ensure_center_layout = function(ev)
  local state = MiniFiles.get_explorer_state()
  if state == nil then
    return
  end

  -- Compute "depth offset" - how many windows are between this and focused
  local path_this = vim.api.nvim_buf_get_name(ev.data.buf_id):match("^minifiles://%d+/(.*)$")
  local depth_this
  for i, path in ipairs(state.branch) do
    if path == path_this then
      depth_this = i
    end
  end
  if depth_this == nil then
    return
  end
  local depth_offset = depth_this - state.depth_focus

  -- Adjust config of this event's window
  local i = math.abs(depth_offset) + 1
  local win_config = vim.api.nvim_win_get_config(ev.data.win_id)
  win_config.width = i <= #widths and widths[i] or widths[#widths]

  win_config.col = math.ceil(0.5 * (vim.o.columns - widths[1]))
  for j = 1, math.abs(depth_offset) do
    local sign = depth_offset == 0 and 0 or (depth_offset > 0 and 1 or -1)
    -- widths[j+1] for the negative case because we don't want to add the center window's width
    local prev_win_width = (sign == -1 and widths[j + 1]) or widths[j] or widths[#widths]
    -- Add an extra +2 each step to account for the border width
    win_config.col = win_config.col + sign * (prev_win_width + 2)
  end

  win_config.height = depth_offset == 0 and 25 or 20
  win_config.row = math.ceil(0.5 * (vim.o.lines - win_config.height))
  -- win_config.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
  vim.api.nvim_win_set_config(ev.data.win_id, win_config)
end

vim.api.nvim_create_autocmd("User", { pattern = "MiniFilesWindowUpdate", callback = ensure_center_layout })

-- NOTE: Center single buffer

-- Our custom wrapper that adds padding
function _G.padded_statuscolumn()
  local full_screen = vim.o.columns
  local winwidth = vim.api.nvim_win_get_width(0)
  local winid = vim.api.nvim_get_current_win()

  -- Get the result from original function
  local ok, lazyvim_util = pcall(require, "lazyvim.util")
  original_column = ok and lazyvim_util.statuscolumn or function()
    return "%l"
  end
  local result = original_column()

  if full_screen >= 100 and winwidth > (full_screen / 2) then
    local padding_width = math.floor((full_screen - 100) / 2)
    -- We need to return a format string that includes padding
    -- The %( and %) create a group, %= pushes to right
    return string.format("%%%d(%%=%s%%)", padding_width, result:gsub("%%!", ""))
  end

  return result
end

-- Update on window events
local events = {
  "BufEnter",
  "BufWinEnter",
  "BufWinLeave",
  "WinEnter",
  "WinLeave",
  "WinResized",
  "VimResized",
}

vim.api.nvim_create_autocmd(events, {
  callback = function()
    vim.o.statuscolumn = [[%!v:lua.padded_statuscolumn()]]
  end,
})
