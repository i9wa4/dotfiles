local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("UDEV Gothic 35LG")
config.font_size = 22
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Window
local opacity_default = 0.70
config.window_background_opacity = opacity_default
config.hide_tab_bar_if_only_one_tab = false

-- Integrated titlebar
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.show_new_tab_button_in_tab_bar = false
config.show_tabs_in_tab_bar = false

config.window_frame = {
	inactive_titlebar_bg = "rgba(0, 0, 0, 0.2)",
	active_titlebar_bg = "rgba(0, 0, 0, 0.2)",
	inactive_titlebar_fg = "#ffffff",
	active_titlebar_fg = "#ffffff",
	font = wezterm.font("UDEV Gothic 35LG"),
	font_size = 20,
}

-- Keybindings
config.disable_default_key_bindings = true

-- macOS: Option as Alt
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

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

config.keys = {
	{ key = "a", mods = "OPT", action = wezterm.action.EmitEvent("inc-opacity") },
	{ key = "s", mods = "OPT", action = wezterm.action.EmitEvent("dec-opacity") },
	{ key = "d", mods = "OPT", action = wezterm.action.IncreaseFontSize },
	{ key = "f", mods = "OPT", action = wezterm.action.DecreaseFontSize },
	{ key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
}

return config
