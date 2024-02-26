vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {'nvim-telescope/telescope.nvim', tag = '0.1.5', dependencies = { 'nvim-lua/plenary.nvim' }},
    { 'rose-pine/neovim', name = 'rose-pine', config = function()
	vim.cmd("colorscheme rose-pine")
    end},
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    {
	"neovim/nvim-lspconfig",
	dependencies = {
	    "hrsh7th/cmp-nvim-lsp",
	    "hrsh7th/cmp-buffer",
	    "hrsh7th/cmp-path",
	    "hrsh7th/cmp-cmdline",
	    "hrsh7th/nvim-cmp",
	    "j-hui/fidget.nvim",
	    "L3MON4D3/LuaSnip",
	},
	config = function() 
	    local cmp = require('cmp')
	    local cmp_lsp = require('cmp_nvim_lsp')
	    local capabilities = vim.tbl_deep_extend(
	    "force",
	    {},
	    vim.lsp.protocol.make_client_capabilities(),
	    cmp_lsp.default_capabilities())

	    require("lspconfig")["texlab"].setup {
		capabilities = capabilities
	    }
	    require("lspconfig")["clangd"].setup {
		capabilities = capabilities
	    }

	    local cmp_select = { behavior = cmp.SelectBehavior.Select }

	    cmp.setup({
		snippet = {
		    expand = function(args)
			require('luasnip').lsp_expand(args.body)
		    end,
		},
		mapping = cmp.mapping.preset.insert({
		    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
		    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
		    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
		    ["<C-Space>"] = cmp.mapping.complete(),
		}),
		sources = cmp.config.sources({
		    { name = 'nvim_lsp' },
		    { name = 'luasnip'},
		}, {
		    { name = 'buffer' },
		})
	    })

	    vim.diagnostic.config({
		-- update_in_insert = true,
		float = {
		    focusable = false,
		    style = "minimal",
		    border = "rounded",
		    source = "always",
		    header = "",
		    prefix = "",
		},
	    })
	end
    }
})

vim.lsp.set_log_level("debug")
