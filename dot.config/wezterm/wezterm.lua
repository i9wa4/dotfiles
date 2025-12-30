local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("UDEV Gothic 35LG")
config.font_size = 24
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
-- config.line_height = 1.5
-- config.freetype_load_target = "Light"
-- config.freetype_render_target = "HorizontalLcd"

-- Window
config.window_background_opacity = 0.80
config.macos_window_background_blur = 20

-- macOS: Option as Alt
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Opacity toggle (Cmd+u)
wezterm.on("toggle-opacity", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.window_background_opacity then
		overrides.window_background_opacity = nil
	else
		overrides.window_background_opacity = 1.0
	end
	window:set_config_overrides(overrides)
end)

config.keys = {
	{ key = "u", mods = "CMD", action = wezterm.action.EmitEvent("toggle-opacity") },
}

return config
