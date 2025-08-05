return {
	"benknoble/vim-synstax",
	-- "imsnif/kdl.vim",

	"dag/vim-fish",
	-- "mhinz/vim-startify",
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	"kyazdani42/nvim-web-devicons",
	"gpanders/editorconfig.nvim",
	{
		"folke/trouble.nvim",
		dependencies = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
		end,
	},
	"pangloss/vim-javascript",
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
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
	"yegappan/mru",
	"Lilja/shevim",
	{ "numToStr/FTerm.nvim" },
	{
		"stevearc/dressing.nvim",
		opts = {},
	},
	{
		"nvim-pack/nvim-spectre",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{ "github/copilot.vim" },
	{ "shortcuts/no-neck-pain.nvim" },
	{ "Lilja/usearch.nvim" },
	{
		"johmsalas/text-case.nvim",
		config = function()
			require("textcase").setup({})
		end,
	},
	{
		"mfussenegger/nvim-lint",
		enable = true,
		config = function()
			require("lint").linters_by_ft = {
				typescript = { "biomejs" },
				typescriptreact = { "biomejs" },
			}
		end,
	}
}
