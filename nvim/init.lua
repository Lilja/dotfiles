vim.o.runtimepath = vim.fn.stdpath("data") .. "/site/pack/*/start/*," .. vim.o.runtimepath
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap =
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
end

vim.cmd([[
set shell=/bin/bash
let g:python3_host_prog = expand('$XDG_CACHE_HOME/neovim/neovim-py/bin/python')
]])
--let g:node_host_prog = trim(system("echo $nvm_data/v18.12.1/bin/node"))

require("packer").startup(function(use)
	use("benknoble/vim-synstax")
	use({ "wbthomason/packer.nvim" })
	use("neovim/nvim-lspconfig") -- Configurations for Nvim LSP
	use("hrsh7th/cmp-nvim-lsp")
	use("ray-x/lsp_signature.nvim")
	use({
		"hrsh7th/nvim-cmp",
		config = function()
			require("config/cmp")
		end,
	})
	use("dag/vim-fish")
	use("mhinz/vim-startify")
	use({
		"lewis6991/gitsigns.nvim",
		-- tag = 'release' -- To use the latest release
	})
	use("kyazdani42/nvim-web-devicons")
	use({
		"nvim-lualine/lualine.nvim",
		requires = {
			"kyazdani42/nvim-web-devicons",
			opt = true,
		},
	})
	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
		config = function()
			require("config/telescope")
			-- require('config/conf_reload')
		end,
	})

	use("folke/tokyonight.nvim")
	use("EdenEast/nightfox.nvim")
	use("andersevenrud/nordic.nvim")
	use({
		"catppuccin/nvim",
		as = "catppuccin",
	})

	use("nvim-treesitter/playground")
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})
	use({ "mrjones2014/legendary.nvim" })

	use("nvim-treesitter/nvim-treesitter-context")
	use("gpanders/editorconfig.nvim")
	-- use 'othree/javascript-libraries-syntax.vim'
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	})
	use({
		"metakirby5/codi.vim",
		config = function() end,
	})
	use("pangloss/vim-javascript")
	use("jose-elias-alvarez/null-ls.nvim")
	use({
		"SmiteshP/nvim-navic",
		requires = "neovim/nvim-lspconfig",
	})

	use({
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	})

	use("nvim-lua/lsp-status.nvim")
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({})
		end,
	})
	use({ "saadparwaiz1/cmp_luasnip" })
	use("imsnif/kdl.vim")
	use({
		"L3MON4D3/LuaSnip",
		after = "nvim-cmp",
		config = function()
			require("luasnip.loaders.from_vscode").load({
				paths = { "~/.config/nvim/custom_snippets" },
			})
		end,
	})
	use("mattn/emmet-vim")
	use("tpope/vim-eunuch")

	use({
		"sbdchd/neoformat",
	})
	use("folke/which-key.nvim")
	use("ThePrimeagen/harpoon")
	use({
		"~/code/zellij.nvim",
		config = function()
			require("zellij").setup({
				debug = false,
				-- replaceVimWindowNavigationKeybinds = true,
				whichKeyEnabled = true,
			})
		end,
	})
	use({
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	})
	use({
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"lua-language-server", -- sumneko_lua
					"rust-analyzer",
					"tailwindcss-language-server", -- tailwindcss
					"typescript-language-server", -- tsserver
					"dockerfile-language-server", -- dockerls
					"gopls",
					"pyright",
					"vue-language-server", -- volar
					"prettier",
					"black",
				},
			})
		end,
	})
	use({
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({})
		end,
	})
	use("vimpostor/vim-tpipeline")

	if packer_bootstrap then
		require("packer").sync()
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
		},
	},
	diagnostics = {
		globals = { "vim" },
	},
}

vim.cmd("filetype plugin on")

vim.g.mapleader = ","
vim.wo.relativenumber = true
vim.wo.number = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 2
vim.o.cursorline = true
vim.cmd("highlight CursorLineNR guifg=#e5c890")
vim.cmd([[
    autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]])
vim.o.termguicolors = true

vim.opt.listchars = {
	tab = "» ",
	extends = "⟩",
	precedes = "⟨",
	trail = "·",
}
vim.opt.list = true
vim.cmd([[
  set tabstop=2
]])

-- Fix when winbar in a release
-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"
	-- ensure_installed = {  },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
require("treesitter-context").setup({
	enable = true,
})
vim.cmd([[ 
  let g:startify_change_to_dir = 0
]])
vim.opt.directory = os.getenv("NVIM_SWAP_DIR")
vim.opt.undodir = os.getenv("NVIM_UNDO_DIR")
vim.opt.undofile = true

function recompile()
	if vim.bo.buftype == "" then
		if vim.fn.exists(":LspStop") ~= 0 then
			vim.cmd("LspStop")
		end

		for name, _ in pairs(package.loaded) do
			if name:match("^user") then
				package.loaded[name] = nil
			end
		end

		dofile(vim.env.MYVIMRC)
		vim.cmd("PackerCompile")
		vim.notify("Wait for Compile Done", vim.log.levels.INFO)
	else
		vim.notify("Not available in this window/buffer", vim.log.levels.INFO)
	end
end
vim.api.nvim_create_user_command("Recompile", function()
	recompile()
end, {})

require("config/lsp_init")
require("config/map")
require("config/lualine")
require("config/theme")
require("config/gitsigns")
