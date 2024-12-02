return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind.nvim",
			"js-everts/cmp-tailwind-colors",
		},
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			local twc = require("cmp-tailwind-colors")
			twc.setup({
				format = function(itemColor)
					return {
						fg = itemColor,
						bg = nil,
						text = "⬤ ",
					}
				end,
			})

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				sources = {
					{ name = "nvim_lua" },
					{ name = "nvim_lsp" },
					{
						name = "buffer",
						keyword_length = 3,
						option = {
							get_bufnrs = function()
								return vim.api.nvim_list_bufs()
							end,
						},
					},
					{ name = "luasnip" },
				},
				mapping = {
					["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
					["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<CR>"] = cmp.mapping(function(fallback)
						if cmp.visible() and cmp.get_selected_entry() then
							cmp.confirm({ select = false })
						else
							fallback()
						end
					end, { "i" }),
					["<UP>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i" }),
					["<DOWN>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i" }),
				},
				window = {
					completion = {
						col_offset = -3, -- align the abbr and word on cursor (due to fields order below)
					},
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = lspkind.cmp_format({
						menu = {
							buffer = "[buf]",
							nvim_lsp = "[LSP]",
							nvim_lua = "[api]",
							path = "[path]",
							luasnip = "[snip]",
							gh_issues = "[issues]",
							tn = "[TabNine]",
						},
						mode = "symbol_text",
						before = function(entry, vim_item)
							if vim_item.kind == "Color" then
								local item = twc.format(entry, vim_item)
								if item.kind == "Color" then
									item.kind = ""
								end
								return item
							end

							vim_item.kind = lspkind.symbolic(vim_item.kind) and lspkind.symbolic(vim_item.kind) or vim_item.kind
							vim_item.kind = vim_item.kind .. " "
							return vim_item
						end,
					}),
				},
			})
		end,
	},
}
