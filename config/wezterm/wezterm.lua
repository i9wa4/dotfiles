local wezterm = require("wezterm")
local config = wezterm.config_builder()
local bongo = wezterm.plugin.require("https://github.com/i9wa4/wezterm-bongo-cat")

-- Keybindings
config.disable_default_key_bindings = true

-- macOS: Option as Alt
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Font
config.font = wezterm.font("UDEV Gothic 35LG")
config.font_size = 20
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Opacity
local opacity_default = 0.70
local titlebar_bg = "none"
local tab_bar_bg = "transparent"

-- Integrated titlebar (fancy tab bar for titlebar transparency control)
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.use_fancy_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.show_tabs_in_tab_bar = false
config.window_frame = {
  font = config.font,
  font_size = config.font_size,
  active_titlebar_bg = titlebar_bg,
  inactive_titlebar_bg = titlebar_bg,
}
config.window_background_opacity = opacity_default
config.status_update_interval = 100 -- 100ms for faster bongo-cat animation
config.hide_tab_bar_if_only_one_tab = false

-- Tab bar background
config.colors = {
  tab_bar = {
    background = tab_bar_bg,
  },
}

-- Status display
local status_fg = "#c0c0c0"
local left_status_bg_alpha = 0.30
local left_status_bg = string.format("rgba(0, 0, 0, %.2f)", left_status_bg_alpha)

wezterm.on("update-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local opacity = overrides.window_background_opacity or opacity_default
  local font_size = window:effective_config().font_size

  -- Right: Cat + Keystroke + Opacity + Font
  local cat_display = bongo.get_display(pane)
  local keystroke_display = bongo.get_keystroke_display()
  local right_text = cat_display
    .. " "
    .. keystroke_display
    .. string.format("%3.0f%% %2.0fpt ", opacity * 100, font_size)
  local right_status_bg = string.format("rgba(0, 0, 0, %.2f)", math.max(opacity, left_status_bg_alpha))
  window:set_right_status(wezterm.format({
    { Background = { Color = right_status_bg } },
    { Foreground = { Color = status_fg } },
    { Text = right_text },
  }))

  -- Left: fill remaining space with dark background
  local dims = pane:get_dimensions()
  local right_width = wezterm.column_width(right_text)
  local left_width = dims.cols - right_width - 2
  if left_width > 0 then
    window:set_left_status(wezterm.format({
      { Background = { Color = left_status_bg } },
      { Text = string.rep(" ", left_width) },
    }))
  end
end)

-- Opacity adjustment (Opt+a: up, Opt+s: down)
wezterm.on("inc-opacity", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.window_background_opacity or opacity_default
  local new_opacity = math.min(current + 0.05, 1.0)
  overrides.window_background_opacity = new_opacity
  window:set_config_overrides(overrides)
end)

wezterm.on("dec-opacity", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.window_background_opacity or opacity_default
  local new_opacity = math.max(current - 0.05, 0.0)
  overrides.window_background_opacity = new_opacity
  window:set_config_overrides(overrides)
end)

-- Font size adjustment (Opt+d: up, Opt+f: down)
local font_size_default = config.font_size
wezterm.on("inc-font-size", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.font_size or font_size_default
  overrides.font_size = current + 1
  window:set_config_overrides(overrides)
end)

wezterm.on("dec-font-size", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.font_size or font_size_default
  overrides.font_size = math.max(current - 1, 6)
  window:set_config_overrides(overrides)
end)

config.keys = {
  { key = "a", mods = "OPT", action = wezterm.action.EmitEvent("inc-opacity") },
  { key = "s", mods = "OPT", action = wezterm.action.EmitEvent("dec-opacity") },
  { key = "d", mods = "OPT", action = wezterm.action.EmitEvent("inc-font-size") },
  { key = "f", mods = "OPT", action = wezterm.action.EmitEvent("dec-font-size") },
  { key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
  { key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
  { key = "l", mods = "CTRL|SHIFT", action = wezterm.action.ShowDebugOverlay }, -- wezterm.plugin.update_all()
}

return config
