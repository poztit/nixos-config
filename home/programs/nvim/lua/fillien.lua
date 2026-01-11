-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require("lazy").setup({
    -- Telescope
    {
	'nvim-telescope/telescope.nvim',
	branch = '0.1.x',
	dependencies = { 'nvim-lua/plenary.nvim' },
	keys = {
	    { '<leader>pf', function() require('telescope.builtin').find_files() end, desc = 'Find files' },
	    { '<C-p>', function() require('telescope.builtin').git_files() end, desc = 'Git files' },
	    { '<leader>ps', function() require('telescope.builtin').live_grep() end, desc = 'Live grep' },
	    { '<leader>pb', function() require('telescope.builtin').buffers() end, desc = 'Buffers' },
	},
    },

    -- Colorscheme
    {
	'catppuccin/nvim',
	name = 'catppuccin',
	lazy = false,
	priority = 1000,
	config = function()
	    require('catppuccin').setup({
		flavour = 'auto',
		background = {
		    light = 'latte',
		    dark = 'mocha',
		},
		integrations = {
		    cmp = true,
		    treesitter = true,
		    telescope = { enabled = true },
		},
	    })
	    vim.cmd.colorscheme('catppuccin')
	end,
    },

    -- Auto dark mode
    {
	'f-person/auto-dark-mode.nvim',
	opts = {
	    update_interval = 1000,
	    set_dark_mode = function()
		vim.o.background = 'dark'
		vim.cmd.colorscheme('catppuccin')
	    end,
	    set_light_mode = function()
		vim.o.background = 'light'
		vim.cmd.colorscheme('catppuccin')
	    end,
	},
    },

    -- Treesitter (main branch - new API)
    {
	'nvim-treesitter/nvim-treesitter',
	branch = 'main',
	build = ':TSUpdate',
	lazy = false,
    },

    -- Completion
    {
	'hrsh7th/nvim-cmp',
	event = 'InsertEnter',
	dependencies = {
	    'hrsh7th/cmp-nvim-lsp',
	    'hrsh7th/cmp-buffer',
	    'hrsh7th/cmp-path',
	    'L3MON4D3/LuaSnip',
	    'saadparwaiz1/cmp_luasnip',
	},
	config = function()
	    local cmp = require('cmp')
	    local luasnip = require('luasnip')

	    cmp.setup({
		snippet = {
		    expand = function(args)
			luasnip.lsp_expand(args.body)
		    end,
		},
		mapping = cmp.mapping.preset.insert({
		    ['<C-p>'] = cmp.mapping.select_prev_item(),
		    ['<C-n>'] = cmp.mapping.select_next_item(),
		    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
		    ['<C-Space>'] = cmp.mapping.complete(),
		    ['<C-e>'] = cmp.mapping.abort(),
		    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
		    ['<C-f>'] = cmp.mapping.scroll_docs(4),
		}),
		sources = cmp.config.sources({
		    { name = 'nvim_lsp' },
		    { name = 'luasnip' },
		    { name = 'path' },
		}, {
		    { name = 'buffer' },
		}),
	    })
	end,
    },

    -- LSP progress indicator
    {
	'j-hui/fidget.nvim',
	opts = {},
    },

    -- Zen mode
    {
	'folke/zen-mode.nvim',
	keys = {
	    {
		'<leader>zz',
		function()
		    require('zen-mode').toggle({
			window = { width = 110 },
		    })
		    vim.wo.number = false
		    vim.wo.relativenumber = false
		end,
		desc = 'Toggle Zen mode',
	    },
	},
    },

    -- Comment
    {
	'numToStr/Comment.nvim',
	opts = {},
    },
})

-- Native LSP Configuration (Neovim 0.11+)
-- Configure LSP servers with vim.lsp.config()
vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

vim.lsp.config('clangd', {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    root_markers = { '.clangd', 'compile_commands.json', '.git' },
})

vim.lsp.config('texlab', {
    cmd = { 'texlab' },
    filetypes = { 'tex', 'plaintex', 'bib' },
    root_markers = { '.latexmkrc', 'latexmkrc', '.git' },
})

vim.lsp.config('nixd', {
    cmd = { 'nixd' },
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', '.git' },
})

vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.stylua.toml', '.git' },
    settings = {
	Lua = {
	    runtime = { version = 'LuaJIT' },
	    workspace = { checkThirdParty = false },
	    telemetry = { enable = false },
	},
    },
})

-- Enable LSP servers
vim.lsp.enable({ 'clangd', 'texlab', 'nixd', 'lua_ls' })

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    float = {
	focusable = false,
	style = 'minimal',
	border = 'rounded',
	source = true,
    },
})

-- LspAttach autocommand for buffer-local keymaps
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
	local opts = { buffer = ev.buf }
	-- Navigation
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
	-- Actions (also available via default grn, gra, grr, gri in 0.11)
	vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
	vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
	vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
	-- Diagnostics
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
	vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    end,
})

-- Additional keymaps
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Enable treesitter highlighting (Neovim 0.11+ native)
vim.api.nvim_create_autocmd('FileType', {
    callback = function()
	pcall(vim.treesitter.start)
    end,
})
