-- wezterm-bongo-cat.lua - BongoCat-style typing indicator for WezTerm
-- Detects cursor movement to show typing animation

local wezterm = require("wezterm")

local M = {}

-- Configuration
M.config = {
  enabled = true,
  typing_timeout = 2, -- seconds to consider as "typing"
}

-- State tracking
local state = {
  last_cursor = { x = 0, y = 0 },
  last_change_time = 0,
  move_count = 0, -- cursor movement count (approx keystrokes)
}

-- Cat expressions
local CAT = {
  idle = "🐱 ⌨️ ", -- waiting
  typing = "😺⌨️💨", -- active typing
}

-- Check if cursor moved and update state
local function update_typing_state(pane)
  local cursor = pane:get_cursor_position()
  local now = os.time()

  -- Cursor moved?
  if cursor.x ~= state.last_cursor.x or cursor.y ~= state.last_cursor.y then
    state.last_change_time = now
    state.last_cursor = { x = cursor.x, y = cursor.y }
    state.move_count = state.move_count + 1
  end

  -- Is typing? (cursor moved within timeout)
  local is_typing = (now - state.last_change_time) < M.config.typing_timeout
  return is_typing
end

-- Get display string
function M.get_display(pane)
  if not M.config.enabled then
    return ""
  end

  local is_typing = update_typing_state(pane)
  return is_typing and CAT.typing or CAT.idle
end

-- Get keystroke count display
function M.get_keystroke_display()
  return string.format("[%d]", state.move_count)
end

return M
