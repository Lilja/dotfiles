function searchCount()
    local search = vim.fn.searchcount({maxcount = 0}) -- maxcount = 0 makes the number not be capped at 99
    local searchCurrent = search.current
    local searchTotal = search.total
    if searchCurrent > 0 and vim.v.hlsearch ~= 0 then
        return "["..searchCurrent.."/"..searchTotal.."]"
    else
        return ""
    end
end
return {
	{
		"folke/tokyonight.nvim",
	},
	{
		"EdenEast/nightfox.nvim",
	},
	"andersevenrud/nordic.nvim",
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			vim.cmd("colorscheme catppuccin")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
			"folke/tokyonight.nvim",
		},
		config = function()
			require("lualine").setup({
				options = {
					section_separators = { left = "" },
					component_separators = { right = "|", left = "|" },
					theme = "catppuccin",
				},
				sections = {
					lualine_b = {
						"branch",
					},
					lualine_c = {
						{ "filename" },
					},
					lualine_x = { searchCount , "encoding", "filetype" },
				},
			})
		end,
	},
}
