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
    {'nvim-telescope/telescope.nvim', tag = '0.1.5', dependencies = {'nvim-lua/plenary.nvim'}},
 --    {'rose-pine/neovim', name = 'rose-pine', config = function()
	-- vim.cmd("colorscheme rose-pine")
 --    end},
    {'EdenEast/nightfox.nvim'},
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    {
	'folke/zen-mode.nvim',
	config = function()
	    vim.keymap.set("n", "<leader>zz", function()
		require("zen-mode").setup {
		    window = {
			width = 110,
			options = {}
		    },
		}
		require("zen-mode").toggle()
		vim.wo.number = false
		vim.wo.rnu = false
	    end)
	end
    },
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
	    'force',
	    {},
	    vim.lsp.protocol.make_client_capabilities(),
	    cmp_lsp.default_capabilities())

	    require('lspconfig')['texlab'].setup {
		capabilities = capabilities
	    }
	    require('lspconfig')['clangd'].setup {
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
		    ['<C-Space>'] = cmp.mapping.complete(),
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
    },
    {
	'numToStr/Comment.nvim',
	config = function()
	    require('Comment').setup()
	end
    }
})


require('nvim-treesitter.configs').setup({
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  -- ensure_installed = { "c", "cpp", "cmake", "lua", "vimdoc", "query" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  -- auto_install = true,

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function()
    vim.cmd("sleep 1m")
    if vim.o.background == "dark" then
      vim.cmd("colorscheme nightfox")
    else
      vim.cmd("colorscheme dayfox")
    end
  end,
})

-- Remap
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {}) 

