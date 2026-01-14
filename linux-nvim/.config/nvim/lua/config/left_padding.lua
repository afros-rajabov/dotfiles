-- Left padding via statuscolumn
-- Adds space on the left **only** when there is exactly one *normal* (non-floating)
-- window open and no non-floating panels (Trouble/Diffview) are visible.
-- Floating windows (snacks picker, mini.files, etc.) do NOT cancel centering.

local M = {}

local config = {
  width = 40,
  enabled = true,
}

local function padding_statuscolumn()
  local padding_spaces = string.rep(" ", config.width)
  -- Format: <padding>%s%=%l
  -- %s = sign column, %= = right align, %l = line number
  return padding_spaces .. "%s%=%l "
end

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
  if has_non_floating_panels() then
    return false
  end

  local wins = get_normal_windows()
  if #wins ~= 1 then
    return false
  end

  -- Important: base the decision on the *editing* window's buffer, not the
  -- current buffer (which could be a floating picker/mini.files).
  local buf = vim.api.nvim_win_get_buf(wins[1])
  return is_normal_file(buf)
end

local function apply_padding(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return
  end

  -- Check if already applied AND verify it's still actually applied
  local current = vim.api.nvim_get_option_value("statuscolumn", { scope = "local", win = win_id })
  if vim.w[win_id].left_padding_applied and current == padding_statuscolumn() then
    return -- Already correctly applied
  end

  -- Store prior value (only if not already stored)
  if not vim.w[win_id].left_padding_applied then
    vim.w[win_id].left_padding_prev_statuscolumn = current
  end
  vim.w[win_id].left_padding_applied = true

  vim.api.nvim_set_option_value("statuscolumn", padding_statuscolumn(), { scope = "local", win = win_id })
end

local function clear_padding(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return
  end

  if vim.w[win_id].left_padding_applied then
    local prev = vim.w[win_id].left_padding_prev_statuscolumn
    -- Restore previous value (empty string restores global/default)
    vim.api.nvim_set_option_value("statuscolumn", prev or "", { scope = "local", win = win_id })
    vim.w[win_id].left_padding_prev_statuscolumn = nil
    vim.w[win_id].left_padding_applied = nil
    return
  end

  -- If a split was created while padding was active, the new window can inherit
  -- our padded statuscolumn without having our window-vars. Detect and clear it.
  local current = vim.api.nvim_get_option_value("statuscolumn", { scope = "local", win = win_id })
  if current == padding_statuscolumn() then
    vim.api.nvim_set_option_value("statuscolumn", "", { scope = "local", win = win_id })
  end
end

local function update()
  if should_show_padding() then
    local wins = get_normal_windows()
    if #wins == 1 then
      apply_padding(wins[1])
    end
  else
    -- Clear from *all* normal windows, not just ones we tracked.
    for _, win_id in ipairs(get_normal_windows()) do
      clear_padding(win_id)
    end
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  local augroup = vim.api.nvim_create_augroup("LeftPadding", { clear = true })
  local update_timer = nil

  local function schedule_update()
    if update_timer then
      update_timer:stop()
    end
    update_timer = vim.defer_fn(update, 50) -- 50ms debounce
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

