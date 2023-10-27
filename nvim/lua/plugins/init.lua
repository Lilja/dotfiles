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
		dependencies = {
			"nvim-lua/plenary.nvim",
			"Lilja/telescope-swap-files",
			"smartpde/telescope-recent-files",
			"camgraff/telescope-tmux.nvim",
			"KadoBOT/nvim-spotify"
		},
		config = function()
			local actions = require("telescope.actions")
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					color_devicons = true,
					layout_strategy = "flex",
					file_ignore_patterns = { "node_modules" },
					-- Default configuration for telescope goes here:
					-- config_key = value,
					mappings = {
						i = { ["<esc>"] = actions.close },
					},
				},
			})

			telescope.load_extension("recent_files")
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
	{
		dir = "/Users/lilja/open-source/cnotes.nvim",
		config = function()
			require('cnotes')
		end,
	},
	{
		"Lilja/cnotes.nvim",
		-- configuration needed!
		config = function()
			require("cnotes").setup({
				-- The ssh host in your ~/.ssh/config to connect to.
				sshHost = "solo",
				-- The directory to locally store journals
				localFileDirectory = os.getenv("HOME") .. "/Documents/journal",
				-- Binary
				syncBinary = "cnotes-sftp-client",
				-- The path on the remote sFTP host of where you want to store files.
				destination = "/volume1/Personal/journal",
				-- When using :Journal, what kind of file type it will be.
				fileExtension = ".md",
			})
		end,
	},
	{ dir = "/home/lilja/code/break.nvim" },
}
