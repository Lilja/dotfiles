-- local navic = require('nvim-navic')
--
require('lualine').setup {
	options = {
  	section_separators = { left = "" },
		theme = 'tokyonight',
	},
	sections = {
		lualine_c = {
						{ "filename" },
						{ "require'lsp-status'.status()" },
		}
	}
}
