local cmp = require('cmp')
cmp.setup {
	sources = {
		{ name = 'nvim_lsp' },
    { name = "buffer" },
	},
	mapping = {
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				print("visible")
				cmp.select_next_item()
			else
				fallback()
			end
		end, { 'i' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { 'i' }),
		['<CR>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.close()
			else
				fallback()
			end
		end, { 'i' }),
		['<UP>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { 'i' }),
		['<DOWN>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { 'i' }),

	}
}
