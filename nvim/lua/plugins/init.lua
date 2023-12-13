return {
	"benknoble/vim-synstax",
	{
		"L3MON4D3/LuaSnip",
	},
	"imsnif/kdl.vim",
	"ray-x/lsp_signature.nvim",
	"onsails/lspkind.nvim",
	
	"dag/vim-fish",
	"mhinz/vim-startify",
	{
		"lewis6991/gitsigns.nvim",
		config = function ()
			require('gitsigns').setup()
		end
	},
	"kyazdani42/nvim-web-devicons",
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/playground",
			"nvim-treesitter/nvim-treesitter-context",
			"windwp/nvim-ts-autotag",
		},
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				autotag = {
					enable = true,
				},
			})
		end,
	},
	"gpanders/editorconfig.nvim",
	{
		"folke/trouble.nvim",
		dependencies = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
		end,
	},
	"pangloss/vim-javascript",
	"jose-elias-alvarez/null-ls.nvim",
	{
		"SmiteshP/nvim-navic",
		dependencies = "neovim/nvim-lspconfig",
	},
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	"nvim-lua/lsp-status.nvim",
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({})
		end,
	},
	"mattn/emmet-vim",
	"tpope/vim-eunuch",
	"sbdchd/neoformat",
	"ThePrimeagen/harpoon",
	{
		"kwkarlwang/bufjump.nvim",
	},
	"yegappan/mru",
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({})
		end,
	},
	{
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
	},

	"Lilja/shevim",
	"davidosomething/format-ts-errors.nvim",
	--[[
	{ "akinsho/flutter-tools.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	--]]
	"b0o/schemastore.nvim",
	--[[
	{
		,
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			local spotify = require("nvim-spotify")
			spotify.setup({})
		end,
		build = "make",
	},
	--]]
	{ "numToStr/FTerm.nvim" },
	{
		"stevearc/dressing.nvim",
		opts = {},
	},
	{ dir = "/home/lilja/code/break.nvim" },
	{
		'nvim-pack/nvim-spectre',
		dependencies = {
			'nvim-lua/plenary.nvim'
		}
	},
	{ 'github/copilot.vim' }
}
