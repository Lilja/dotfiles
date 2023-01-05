local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
	sources = {
    { name = "nvim_lua" },
		{ name = 'nvim_lsp' },
    { name = "buffer", keyword_length = 3 },
    { name = "luasnip" },
	},
	mapping = {
		['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i','c'}),
		['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i','c'}),
		['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
		["<C-y>"] = cmp.mapping(function ()
			print("Lol")
      cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }
			end, { "i", "c" }
    ),
		['<CR>'] = cmp.mapping(function(fallback)
			if cmp.visible() and cmp.get_selected_entry() then
				cmp.confirm({select = false })
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

	},
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[api]",
        path = "[path]",
        luasnip = "[snip]",
        gh_issues = "[issues]",
        tn = "[TabNine]",
      },
    },
  },
}
