return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = 'main',
		dependencies = {
			-- "nvim-treesitter/playground",
			"nvim-treesitter/nvim-treesitter-context",
			"windwp/nvim-ts-autotag",
			"HiPhish/rainbow-delimiters.nvim",
		},
		build = ":TSUpdate",
		config = function()
			require("treesitter-context").setup({
				enable = true,
				max_lines = 20,
				multiline_threshold = 10,
			})
			require('nvim-ts-autotag').setup()
		end,
	},
}
