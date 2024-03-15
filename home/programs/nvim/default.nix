{
  programs.neovim = {
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      telescope
      rose-pine
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      fidget-nvim
      luasnip
    ];
  };
}
