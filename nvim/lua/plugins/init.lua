return {
	"benknoble/vim-synstax",
	"neovim/nvim-lspconfig",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-nvim-lua",
	"hrsh7th/cmp-buffer",
	{
		"L3MON4D3/LuaSnip",
	},
	{ "saadparwaiz1/cmp_luasnip" },
	"imsnif/kdl.vim",
	"ray-x/lsp_signature.nvim",
	"onsails/lspkind.nvim",
	{ "hrsh7th/nvim-cmp" },
	"dag/vim-fish",
	"mhinz/vim-startify",
	{
		"lewis6991/gitsigns.nvim",
		-- tag = 'release' -- To use the latest release
	},
	"kyazdani42/nvim-web-devicons",
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
			lazy = true,
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local actions = require("telescope.actions")
			require("telescope").setup({
				defaults = {
					color_devicons = true,
					file_ignore_patterns = { "node_modules" },
					-- Default configuration for telescope goes here:
					-- config_key = value,
					mappings = {
						 i = { ["<esc>"] = actions.close, }
					},
				},
			})
		end,
	},
	"folke/tokyonight.nvim",
	"EdenEast/nightfox.nvim",
	"andersevenrud/nordic.nvim",
	{
		"catppuccin/nvim",
		name = "catppuccin",
	},
	"nvim-treesitter/playground",
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},
	{ "mrjones2014/legendary.nvim" },
	"nvim-treesitter/nvim-treesitter-context",
	"gpanders/editorconfig.nvim",
	{
		"folke/trouble.nvim",
		dependencies = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
		end,
	},
	{
		"metakirby5/codi.vim",
		config = function() end,
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
		-- "lilja/lsp-luasnip",
		"Lilja/lsp-luasnip",
		-- requires = {"L3MON4D3/LuaSnip", "neovim/nvim-lspconfig"},
	},
	-- use 'numToStr/prettierrc.nvim'
	{
		"kwkarlwang/bufjump.nvim",
	},
	{
		"lilja/zellij.nvim",
		config = function()
			require("zellij").setup({})
		end,
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
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-treesitter.configs").setup({
				autotag = {
					enable = true,
				},
			})
		end,
	},
	"Lilja/shevim",
	"davidosomething/format-ts-errors.nvim",
	{ "akinsho/flutter-tools.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	"b0o/schemastore.nvim",
	{
		"KadoBOT/nvim-spotify",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			local spotify = require("nvim-spotify")
			spotify.setup({})
		end,
		build = "make",
	},
	{ "numToStr/FTerm.nvim" },
	{ "camgraff/telescope-tmux.nvim" },
	{ "Lilja/telescope-swap-files", dependencies = { "nvim-telescope/telescope.nvim" } },
	{
		"stevearc/dressing.nvim",
		opts = {},
	},
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
}
