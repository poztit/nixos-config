local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Load the built-in color schemes
local dark_theme = wezterm.color.get_builtin_schemes()['nightfox']
dark_theme.selection_bg = '#e0def4'
dark_theme.selection_fg = '#191724'

local light_theme = wezterm.color.get_builtin_schemes()['dayfox']
light_theme.selection_bg = '#e0def4'
light_theme.selection_fg = '#191724'

-- Add the customized schemes
config.color_schemes = {
  ['dark'] = dark_theme,
  ['light'] = light_theme,
}

-- Detect the system theme and set the appropriate color scheme
local appearance = wezterm.gui.get_appearance()
if appearance:find('Dark') then
  config.color_scheme = 'dark'
else
  config.color_scheme = 'light'
end

-- Other configurations
config.enable_wayland = false
config.font = wezterm.font("Iosevka Nerd Font Mono", {weight="Regular", stretch="Normal", style="Normal"})
config.font_size = 13
config.hide_mouse_cursor_when_typing = false
config.custom_block_glyphs = false
config.front_end = "WebGpu"
config.enable_tab_bar = false;
-- Disable confirmation prompts when closing windows/tabs
config.window_close_confirmation = "NeverPrompt"
-- Increase initial window width (in terminal columns)
config.initial_cols = 140

return config
