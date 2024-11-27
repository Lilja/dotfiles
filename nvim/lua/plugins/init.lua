return {
	"benknoble/vim-synstax",
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			local ls = require("luasnip")
			local snippet = ls.snippet
			local text = ls.text_node
			local insert = ls.insert_node

			local vue3_component_creation_snippet = snippet({
				trig = "vue 3 script+template",
				dscr = "Vue 3 script(setup)+template",
			}, {
				text({ '<script lang="ts" setup>', 'import {ref, computed, PropType } from "vue"', "", "" }),
				insert(1, ""),
				text({
					"const props = defineProps({",
					"  type: {",
					"    required: true,",
					"    type: String as PropType<string>,",
					"  }",
					"})",
					"</script>",
					"",
					"<template>",
					"  <div>",
					"   ",
					"  </div>",
					"</template>",
				}),
			})
			local vitest_test_case = snippet({
				trig = "vitest test case pattern",
				dscr = "Vitest test case",
			}, {
				text({
					'import { expect, test } from "vitest";',
					"",
					'test("1+1=2", () => {',
					"  expect(",
				}),
				insert(1, "1+1"),
				text({ ").toBe(2);", "});" }),
			})
			ls.add_snippets("vue", { vue3_component_creation_snippet })
			ls.add_snippets("typescript", { vitest_test_case })
		end,
	},
	"imsnif/kdl.vim",
	"ray-x/lsp_signature.nvim",
	"onsails/lspkind.nvim",

	"dag/vim-fish",
	"mhinz/vim-startify",
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	"kyazdani42/nvim-web-devicons",
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/playground",
			"nvim-treesitter/nvim-treesitter-context",
			"windwp/nvim-ts-autotag",
		},
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				autotag = {
					enable = true,
				},
			})
		end,
	},
	"gpanders/editorconfig.nvim",
	{
		"folke/trouble.nvim",
		dependencies = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
		end,
	},
	"pangloss/vim-javascript",
	"jose-elias-alvarez/null-ls.nvim",
	{
		"SmiteshP/nvim-navic",
		dependencies = "neovim/nvim-lspconfig",
	},
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	"nvim-lua/lsp-status.nvim",
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({})
		end,
	},
	"mattn/emmet-vim",
	"tpope/vim-eunuch",
	"sbdchd/neoformat",
	"ThePrimeagen/harpoon",
	{
		"kwkarlwang/bufjump.nvim",
	},
	"yegappan/mru",
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"lua-language-server", -- sumneko_lua
					"rust-analyzer",
					"tailwindcss-language-server", -- tailwindcss
					"typescript-language-server", -- ts_ls / tsserver
					"dockerfile-language-server", -- dockerls
					"gopls",
					"pyright",
					"vue-language-server", -- volar
					"prettier",
					"black",
					"jsonls",
				},
			})
		end,
	},
	"Lilja/shevim",
	"davidosomething/format-ts-errors.nvim",
	"b0o/schemastore.nvim",
	{ "numToStr/FTerm.nvim" },
	{
		"stevearc/dressing.nvim",
		opts = {},
	},
	{ dir = "/home/lilja/code/break.nvim" },
	{
		"nvim-pack/nvim-spectre",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{ "github/copilot.vim" },
	{ "shortcuts/no-neck-pain.nvim" },
	{
		"numToStr/FTerm.nvim",
	},
}
