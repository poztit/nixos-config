local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

local rosepine = wezterm.color.get_builtin_schemes()['rose-pine']
rosepine.selection_bg = '#000000'
rosepine.selection_fg = '#ffffff'

config.color_schemes = { ['rose-pine'] = rosepine }
config.enable_wayland = false
config.font_size = 10
config.color_scheme = 'rose-pine'
config.hide_mouse_cursor_when_typing = false

return config
