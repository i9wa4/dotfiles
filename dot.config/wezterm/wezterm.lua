local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("UDEV Gothic 35LG")
config.font_size = 24
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Window
config.window_background_opacity = 0.80
config.hide_tab_bar_if_only_one_tab = true

-- macOS: Option as Alt
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Opacity adjustment (Opt+a: up, Opt+s: down)
local opacity_default = 0.80

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

config.keys = {
	{ key = "a", mods = "OPT", action = wezterm.action.EmitEvent("inc-opacity") },
	{ key = "s", mods = "OPT", action = wezterm.action.EmitEvent("dec-opacity") },
}

return config
