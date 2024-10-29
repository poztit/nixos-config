local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

local rosepine = wezterm.color.get_builtin_schemes()['rose-pine']
rosepine.selection_bg = '#e0def4'
rosepine.selection_fg = '#191724'

config.color_schemes = { ['rose-pine'] = rosepine }
config.enable_wayland = false
config.font = wezterm.font("JetBrains Mono", {weight="Regular", stretch="Normal", style="Normal"})
config.font_size = 10
config.color_scheme = 'rose-pine'
config.hide_mouse_cursor_when_typing = false
config.custom_block_glyphs = false
config.front_end = "WebGpu"

return config
