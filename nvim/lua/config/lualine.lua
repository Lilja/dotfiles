require('lualine').setup {
	options = {
		theme = 'tokyonight',
		sections = {
			lualine_c = { "os.date('%a')", 'data', "require'lsp-status'.status()" }
		}
	}
}
