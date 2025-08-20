{ pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  xdg.configFile."wezterm/colors/dayfox.toml".source = ./colors/dayfox.toml;
}
