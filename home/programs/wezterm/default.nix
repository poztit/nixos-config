{ pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".wezterm.lua".source = ./wezterm.lua;
}
