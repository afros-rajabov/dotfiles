-- Left padding via statuscolumn
-- Adds space on the left **only** when there is exactly one *normal* (non-floating)
-- window open and no non-floating panels (Trouble/Diffview) are visible.
-- Floating windows (snacks picker, mini.files, etc.) do NOT cancel centering.

local M = {}

local config = {
  width = 40,
  enabled = true,
}

-- Track which windows we've modified, so we can undo cleanly
local padded_wins = {}

local function is_floating_window(win_id)
  local ok, win_config = pcall(vim.api.nvim_win_get_config, win_id)
  if not ok then
    return false
  end
  return win_config.relative ~= ""
end

local function get_normal_windows()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not is_floating_window(win) then
      table.insert(wins, win)
    end
  end
  return wins
end

local function is_single_normal_window()
  return #get_normal_windows() == 1
end

local function is_panel_buffer(buf_id)
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    return false
  end

  local buf_name = vim.api.nvim_buf_get_name(buf_id)
  local filetype = vim.api.nvim_buf_get_option(buf_id, "filetype")

  if filetype == "Trouble" or filetype == "DiffviewFiles" then
    return true
  end

  if buf_name:match("^trouble://") or buf_name:match("^diffview://") then
    return true
  end

  return false
end

local function has_non_floating_panels()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not is_floating_window(win) then
      local buf_id = vim.api.nvim_win_get_buf(win)
      if is_panel_buffer(buf_id) then
        return true
      end
    end
  end
  return false
end

local function is_normal_file(buf_id)
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    return false
  end

  local buf_name = vim.api.nvim_buf_get_name(buf_id)
  -- Exclude special buffers (unnamed, URI-like, etc.)
  if buf_name == "" or buf_name:match("^[%w]+://") then
    return false
  end

  return true
end

local function should_show_padding()
  if not config.enabled then
    return false
  end
  if not is_single_normal_window() then
    return false
  end
  if has_non_floating_panels() then
    return false
  end

  return is_normal_file(vim.api.nvim_get_current_buf())
end

local function apply_padding(win_id)
  if not vim.api.nvim_win_is_valid(win_id) or padded_wins[win_id] then
    return
  end

  local padding_spaces = string.rep(" ", config.width)
  -- Format: <padding>%s%=%l
  -- %s = sign column, %= = right align, %l = line number
  local statuscolumn = padding_spaces .. "%s%=%l "

  vim.api.nvim_set_option_value("statuscolumn", statuscolumn, { scope = "local", win = win_id })
  padded_wins[win_id] = true
end

local function clear_padding(win_id)
  if not vim.api.nvim_win_is_valid(win_id) or not padded_wins[win_id] then
    return
  end

  -- Empty resets to default/global
  vim.api.nvim_set_option_value("statuscolumn", "", { scope = "local", win = win_id })
  padded_wins[win_id] = nil
end

local function update()
  -- cleanup invalid windows
  for win_id, _ in pairs(padded_wins) do
    if not vim.api.nvim_win_is_valid(win_id) then
      padded_wins[win_id] = nil
    end
  end

  if should_show_padding() then
    local wins = get_normal_windows()
    if #wins == 1 then
      apply_padding(wins[1])
    end
  else
    for win_id, _ in pairs(padded_wins) do
      clear_padding(win_id)
    end
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  local augroup = vim.api.nvim_create_augroup("LeftPadding", { clear = true })
  local function schedule_update()
    vim.defer_fn(update, 10)
  end

  vim.api.nvim_create_autocmd({ "WinNew", "WinClosed" }, {
    group = augroup,
    callback = schedule_update,
    desc = "LeftPadding: window changes",
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave" }, {
    group = augroup,
    callback = schedule_update,
    desc = "LeftPadding: buffer changes",
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    callback = schedule_update,
    desc = "LeftPadding: focus changes",
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = schedule_update,
    desc = "LeftPadding: resize",
  })

  vim.defer_fn(update, 100)
end

return M

