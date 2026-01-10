local wezterm = require("wezterm")
local config = wezterm.config_builder()
local bongo = require("wezterm-bongo-cat")

-- Keybindings
config.disable_default_key_bindings = true

-- macOS: Option as Alt
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Font
config.font = wezterm.font("UDEV Gothic 35LG")
config.font_size = 20
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Integrated titlebar
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.show_new_tab_button_in_tab_bar = false
config.show_tabs_in_tab_bar = false

-- Window
config.window_frame = {
  active_titlebar_bg = "rgba(0, 0, 0, 0.2)",
  inactive_titlebar_bg = "rgba(0, 0, 0, 0.2)",
  active_titlebar_fg = "#FFFFFF",
  inactive_titlebar_fg = "#FFFFFF",
  active_titlebar_border_bottom = "none",
  inactive_titlebar_border_bottom = "none",
  button_bg = "none",
  button_fg = "#FFFFFF",
  button_hover_bg = "rgba(255, 255, 255, 0.1)",
  button_hover_fg = "#FFFFFF",
  font = wezterm.font("UDEV Gothic 35LG"),
  font_size = 20, -- the same as Chrome titlebar height
}

local opacity_default = 0.70
config.window_background_opacity = opacity_default
config.hide_tab_bar_if_only_one_tab = false

-- Tab bar colors (match titlebar)
config.colors = {
  tab_bar = {
    background = "rgba(0, 0, 0, 0.2)",
  },
}

-- Status display
local status_fg = "#FFFFFF"

wezterm.on("update-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local opacity = overrides.window_background_opacity or opacity_default
  local font_size = window:effective_config().font_size

  -- Right: Cat + Keystroke + Opacity + Font
  local cat_display = bongo.get_display(pane)
  local keystroke_display = bongo.get_keystroke_display()
  local right_status = string.format(" %3.0f%% %2.0fpt ", opacity * 100, font_size)
  window:set_right_status(wezterm.format({
    { Background = { Color = "rgba(0, 0, 0, 0.2)" } },
    { Foreground = { Color = status_fg } },
    { Text = cat_display .. " " .. keystroke_display .. right_status },
  }))

  -- Left: empty (space for macOS window buttons)
  window:set_left_status("")
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
}

return config
