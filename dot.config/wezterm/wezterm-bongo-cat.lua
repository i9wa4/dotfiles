-- wezterm-bongo-cat.lua

local M = {}

M.config = {
  enabled = true,
  typing_timeout = 2,
  sleep_timeout = 30,
  combo_timeout = 3,
}

local state = {
  last_cursor = { x = 0, y = 0 },
  last_change_time = 0,
  move_count = 0,
  combo_count = 0,
}

local FACE = { normal = "^•ω•^", effort = "^>ω<^", sleepy = "^-ω-^" }

function M.get_display(pane)
  if not M.config.enabled then
    return ""
  end

  local cursor = pane:get_cursor_position()
  local now = os.time()
  local idle_time = now - state.last_change_time

  -- Reset combo if idle too long
  if idle_time >= M.config.combo_timeout then
    state.combo_count = 0
  end

  -- Cursor moved?
  if cursor.x ~= state.last_cursor.x or cursor.y ~= state.last_cursor.y then
    state.last_change_time = now
    state.last_cursor = { x = cursor.x, y = cursor.y }
    state.move_count = state.move_count + 1
    state.combo_count = state.combo_count + 1
  end

  idle_time = now - state.last_change_time

  if idle_time >= M.config.sleep_timeout then
    return "ฅ" .. FACE.sleepy .. "ฅ"
  elseif idle_time >= M.config.typing_timeout then
    return "ฅ" .. FACE.normal .. "ฅ"
  else
    local left = state.move_count % 2 == 0 and " " or "ฅ"
    local right = state.move_count % 2 == 0 and "ฅ" or " "
    return left .. FACE.effort .. right
  end
end

function M.get_keystroke_display()
  return string.format("[%d]", state.move_count)
end

function M.get_combo_display()
  if state.combo_count > 0 then
    return string.format("%dcombo", state.combo_count)
  end
  return ""
end

return M
