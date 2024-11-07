local flavour = "mocha"
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
		"catppuccin/nvim",
		dependencies = {
			"ntpeters/vim-better-whitespace",
		},
		name = "catppuccin",
		config = function()
			local colors = require("catppuccin.palettes").get_palette(flavour)
			vim.cmd.colorscheme("catppuccin-" .. flavour)
			vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = colors.red })
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
			"catppuccin/nvim",
		},
		config = function()
			require("lualine").setup({
				options = {
					-- section_separators = { left = "" },
					-- component_separators = { right = "|", left = "|" },
					component_separators = " ",
					section_separators = { left = "", right = "" },
					theme = "catppuccin-" .. flavour,
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
