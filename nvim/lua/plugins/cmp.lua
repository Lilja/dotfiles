return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")

			local flag = false
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
					["<C-y>"] = cmp.mapping(function()
						print("Lol")
						cmp.mapping.confirm({
							behavior = cmp.ConfirmBehavior.Insert,
							select = true,
						})
					end, { "i", "c" }),
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
						before = function(entry, vim_item) -- for tailwind css autocomplete
							if vim_item.kind == "Color" and entry.completion_item.documentation then
								local _, _, r, g, b = string.find(entry.completion_item.documentation, "^rgb%((%d+), (%d+), (%d+)")
								if r then
									local color = string.format("%02x", r) .. string.format("%02x", g) .. string.format("%02x", b)
									local group = "Tw_" .. color
									if vim.fn.hlID(group) < 1 then
										vim.api.nvim_set_hl(0, group, { fg = "#" .. color })
									end
									vim_item.kind = "⬤ "
									vim_item.kind_hl_group = group
									return vim_item
								end
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
