local cmp = require('cmp')

cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
	sources = {
		{ name = 'nvim_lsp' },
    { name = "buffer" },
    { name = "luasnip" },
	},
	mapping = {
		['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i','c'}),
		['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i','c'}),
		['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
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
				cmp.confirm({select = true})
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
