-- wezterm-bongo-cat.lua

local M = {}

M.config = {
  enabled = true,
  typing_timeout = 2,
  sleep_timeout = 30,
  random_interval = 5,
  hand = { up = "ฅ", down = "₀" },
  face = {
    normal = "^•ω•^",
    effort = "^>ω<^",
    sleepy = { "^-ω-^", "^=ω=^" },
  },
}

local state = {
  last_cursor = { x = 0, y = 0 },
  last_change_time = 0,
  move_count = 0,
}

local function random_choice(tbl)
  math.randomseed(math.floor(os.time() / M.config.random_interval))
  return tbl[math.random(#tbl)]
end

function M.get_display(pane)
  if not M.config.enabled then
    return ""
  end

  local cursor = pane:get_cursor_position()
  local now = os.time()

  if cursor.x ~= state.last_cursor.x or cursor.y ~= state.last_cursor.y then
    state.last_change_time = now
    state.last_cursor = { x = cursor.x, y = cursor.y }
    state.move_count = state.move_count + 1
  end

  local idle_time = now - state.last_change_time
  local hand = M.config.hand
  local face = M.config.face

  if idle_time >= M.config.sleep_timeout then
    local sleepy = type(face.sleepy) == "table" and random_choice(face.sleepy) or face.sleepy
    return hand.up .. sleepy .. hand.up
  elseif idle_time >= M.config.typing_timeout then
    return hand.up .. face.normal .. hand.up
  else
    local left = state.move_count % 2 == 0 and hand.up or hand.down
    local right = state.move_count % 2 == 0 and hand.down or hand.up
    return left .. face.effort .. right
  end
end

function M.get_keystroke_display()
  return string.format("[%d]", state.move_count)
end

return M
