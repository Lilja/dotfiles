vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
		install_path })
end


vim.cmd [[
let g:python3_host_prog = expand('$XDG_CACHE_HOME/neovim/neovim-env/bin/python')
]]

require('packer').startup(function(use)
	use 'benknoble/vim-synstax'
	use { "wbthomason/packer.nvim" }
	use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
	use 'hrsh7th/cmp-nvim-lsp'
	use "ray-x/lsp_signature.nvim"
	use 'hrsh7th/nvim-cmp'
	use 'dag/vim-fish'
	use 'mhinz/vim-startify'
	use {
		'lewis6991/gitsigns.nvim',
		-- tag = 'release' -- To use the latest release
	}
	use {
		'nvim-lualine/lualine.nvim',
		requires = {
			'kyazdani42/nvim-web-devicons', opt = true
		}
	}
	use {
		'nvim-telescope/telescope.nvim',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}


	use 'folke/tokyonight.nvim'
	use({
		"catppuccin/nvim",
		as = "catppuccin"
	})

	use 'nvim-treesitter/playground'
	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate'
	}

	use 'nvim-treesitter/nvim-treesitter-context'
	use 'gpanders/editorconfig.nvim'
	-- use 'othree/javascript-libraries-syntax.vim'
	use {
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			}
		end
	}
	-- use 'pangloss/vim-javascript'
	use 'jose-elias-alvarez/null-ls.nvim'
	use {
		"SmiteshP/nvim-navic",
		requires = "neovim/nvim-lspconfig"
	}

	use 'nvim-lua/lsp-status.nvim'
	use 'posva/vim-vue'
	use { 'saadparwaiz1/cmp_luasnip' }
	use { 'L3MON4D3/LuaSnip', after = 'nvim-cmp' }
	use 'tpope/vim-eunuch'

	use 'sbdchd/neoformat'
	use 'ThePrimeagen/harpoon'

	if packer_bootstrap then
		require('packer').sync()
	end
end)

Lua = {
	format = {
		enable = true,
		-- Put format options here
		-- NOTE: the value should be STRING!!
		defaultConfig = {
			indent_style = "space",
			indent_size = "2",
		}
	},
	diagnostics = {
		globals = { 'vim' }
	}
}

vim.cmd('filetype plugin on')

vim.wo.relativenumber = true
vim.wo.number = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 2
vim.o.cursorline = true
vim.cmd('highlight CursorLineNR guifg=#e5c890')
vim.cmd [[
    autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]]
vim.o.termguicolors = true

vim.opt.listchars = {
	tab = '» ',
	extends = '⟩',
	precedes = '⟨',
	trail = '·'
}
vim.opt.list = true
vim.cmd [[
  set tabstop=2
]]
-- Fix when winbar in a release
-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

require 'nvim-treesitter.configs'.setup {
	-- A list of parser names, or "all"
	-- ensure_installed = {  },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	}
}
require 'treesitter-context'.setup {
	enable = true,
}
--require 'treesitter-context'.setup {
--	enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
--}
--
vim.cmd [[ 
  let g:startify_change_to_dir = 0
]]
vim.opt.directory = os.getenv("NVIM_SWAP_DIR")
vim.opt.undodir = os.getenv("NVIM_UNDO_DIR")
vim.opt.undofile = true

require('config/telescope')
require('config/lsp_init')
require('config/cmp')
require('config/map')
require('config/lualine')
require('config/theme')
require('config/gitsigns')
