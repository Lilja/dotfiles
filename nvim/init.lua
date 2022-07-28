vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
end

require('packer').startup(function(use)
	use { "wbthomason/packer.nvim" }
	use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/nvim-cmp'
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
	use 'gpanders/editorconfig.nvim'
	-- use 'othree/javascript-libraries-syntax.vim'
	use 'pangloss/vim-javascript'
	use 'jose-elias-alvarez/null-ls.nvim'
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
vim.g.catppuccin_flavour = "frappe" -- latte, frappe, macchiato, mocha
-- vim.cmd [[colorscheme catppuccin]]
vim.cmd [[colorscheme tokyonight]]

vim.wo.relativenumber = true
vim.wo.number = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 2
vim.o.cursorline = true
vim.cmd('highlight CursorLineNR guifg=#e5c890')
vim.cmd [[
				autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]]

require 'nvim-treesitter.configs'.setup {
	-- A list of parser names, or "all"
	ensure_installed = { "css", "typescript", "vue" },
	enable = true,
}


require('config/lsp_init')
require('config/cmp')
require('config/map')
require('config/lualine')
