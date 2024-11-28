--- @param name string
local function file_exists(name)
	local f = io.open(name, "r")
	return f ~= nil and io.close(f)
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "hrsh7th/cmp-nvim-lsp" },
	},
	config = function()
		local util = require("lspconfig/util")

		-- Function to find the deepest root based on root patterns
		-- https://chatgpt.com/share/67175ecd-1c48-8009-a0d8-dee4ff1c2be5
		local function find_deepest_root(startpath, root_files)
			local deepest_root = nil
			local deepest_depth = -1

			-- Iterate through each root pattern
			for _, pattern in ipairs(root_files) do
				local root_dir = util.root_pattern(pattern)(startpath)

				if root_dir then
					-- Calculate depth (number of slashes in the path)
					local depth = #vim.split(root_dir, "/")

					-- If this root is deeper, update deepest_root and deepest_depth
					if depth > deepest_depth then
						deepest_root = root_dir
						deepest_depth = depth
					end
				end
			end

			return deepest_root
		end

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local volarCapabilities = capabilities
		volarCapabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		-- require('vim.lsp._watchfiles')._watchfunc = function(_, _, _) return true end

		require("lsp_signature").setup({
			hint_enable = false,
		})
		local navic = require("nvim-navic")
		navic.setup({})

		function OpenDiagnosticIfNoFloat()
			-- https://github.com/nvim-treesitter/nvim-treesitter-context/issues/531
			for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
				local config = vim.api.nvim_win_get_config(winid)
				if config.split == nil and config.focusable then
					return
				end
			end
			-- THIS IS FOR BUILTIN LSP
			vim.diagnostic.open_float(nil, {
				scope = "cursor",
				focusable = false,
				close_events = {
					"CursorMoved",
					"CursorMovedI",
					"BufHidden",
					"InsertCharPre",
					"WinLeave",
				},
			})
		end

		local on_attach = function(client, bufnr)
			-- Enable completion triggered by <c-x><c-o>
			vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

			vim.o.updatetime = 250

			vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
			vim.api.nvim_create_autocmd({ "CursorHold" }, {
				pattern = "*",
				command = "lua OpenDiagnosticIfNoFloat()",
				group = "lsp_diagnostics_hold",
			})
			vim.diagnostic.config({
				virtual_text = false,
			})

			-- Mappings.
			-- See `:help vim.lsp.*` for documentation on any of the below functions
			local bufopts = { noremap = true, silent = true, buffer = bufnr }
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
			vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
			vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
			vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
			vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
			vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
			vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
			-- vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)

			if client.server_capabilities.documentSymbolProvider then
				if client.name ~= "volar" then
					navic.attach(client, bufnr)
				end
			end
		end

		local function get_python_path(workspace)
			-- Use activated virtualenv.
			if vim.env.VIRTUAL_ENV then
				return util.path.join(vim.env.VIRTUAL_ENV, "bin", "python")
			end

			-- Find and use virtualenv from pipenv in workspace directory.
			local pipenvMatch = vim.fn.glob(util.path.join(workspace, "Pipfile"))
			if pipenvMatch ~= "" then
				local venv = vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. pipenvMatch .. " pipenv --venv"))
				return util.path.join(venv, "bin", "python")
			end

			-- Find and use virtualenv from poetry in workspace directory.
			local poetryMatch = vim.fn.glob(util.path.join(workspace, "poetry.lock"))
			if poetryMatch ~= "" then
				local poetry = vim.fn.trim(vim.fn.system("poetry --directory " .. workspace .. " env info -p"))
				return util.path.join(poetry, "bin", "python")
			end

			-- Find virtualenvs
			local venvMatch = vim.fn.glob(util.path.join(workspace, "venv"))
			if file_exists(venvMatch) then
				return util.path.join(venvMatch, "bin", "python")
			end

			-- Fallback to system Python.
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end

		require("lspconfig")["pyright"].setup({
			on_attach = on_attach,
			before_init = function(_, config)
				config.settings.python.pythonPath = get_python_path(config.root_dir)
			end,
			root_dir = function(fname)
				local root_pattern = {
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					"Pipfile",
					"pyrightconfig.json",
					".git",
				}

				return find_deepest_root(fname, root_pattern)
			end,
		})

		local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
		local volar_path = mason_packages .. "/vue-language-server/node_modules/@vue/language-server"
		local extracedTsserver = mason_packages .. "/typescript-language-server/node_modules/typescript/lib"
		local tsserverPath = mason_packages .. "/typescript-language-server/node_modules/.bin/"

		require("lspconfig")["volar"].setup({
			on_attach = on_attach,
			capabilities = volarCapabilities,
			-- cmd = { nodeDevEnvPath .. "vue-language-server", "--stdio" },
			init_options = {
				typescript = {
					tsdk = extracedTsserver,
				},
			},
		})
		require("lspconfig")["clojure_lsp"].setup({
			on_attach = on_attach,
			capabilities = volarCapabilities,
		})

		require("lspconfig")["astro"].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})

		require("lspconfig")["dockerls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
		require("lspconfig")["lua_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			on_init = function(client)
				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						-- Tell the language server which version of Lua you're using
						-- (most likely LuaJIT in the case of Neovim)
						version = "LuaJIT",
					},
					-- Make the server aware of Neovim runtime files
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
							-- Depending on the usage, you might want to add additional paths here.
							-- "${3rd}/luv/library"
							-- "${3rd}/busted/library",
						},
						-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
						-- library = vim.api.nvim_get_runtime_file("", true)
					},
				})
			end,
			settings = {
				Lua = {},
			},
		})

		require("lspconfig")["ts_ls"].setup({
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = volar_path,
						languages = { "javascript", "typescript", "vue", "tsx", "jsx", "typescriptreact" },
					},
				},
			},
			filetypes = {
				"javascript",
				"typescript",
				"typescriptreact",
				"tsx",
				"jsx",
				"vue",
			},
			on_attach = on_attach,
			capabilities = capabilities,
			cmd = { tsserverPath .. "typescript-language-server", "--stdio" },
			handlers = {
				["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
					if result.diagnostics == nil then
						return
					end

					-- ignore some ts_ls / tsserver diagnostics
					local idx = 1
					while idx <= #result.diagnostics do
						local entry = result.diagnostics[idx]

						local formatter = require("format-ts-errors")[entry.code]
						entry.message = formatter and formatter(entry.message) or entry.message

						-- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
						if entry.code == 80001 then
							-- { message = "File is a CommonJS module; it may be converted to an ES module.", }
							table.remove(result.diagnostics, idx)
						else
							idx = idx + 1
						end
					end

					vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
				end,
			},
		})
		require("lspconfig")["gopls"].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		require("lspconfig")["rust_analyzer"].setup({
			on_attach = on_attach,
			settings = {
				["rust-analyzer"] = {
					imports = {
						granularity = {
							group = "module",
						},
						prefix = "self",
					},
					cargo = {
						buildScripts = {
							enable = true,
						},
					},
					procMacro = {
						enable = true,
					},
				},
			},
		})

		require("lspconfig")["tailwindcss"].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})

		require("lspconfig")["jsonls"].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				json = {
					schemas = require("schemastore").json.schemas({
						extra = {
							{
								description = "Funnel Source Type Config Schema",
								name = "funnel_source_type.json",
								fileMatch = { "**/source_type_configs/*.json" },
								url = "https://connector-web.funnel.io/source-type-config-schema.json",
							},
							{
								description = "Funnel Connection Type Config Schema",
								fileMatch = { "**/connections/*.json" },
								name = "funnel_credential_connection.json",
								uri = "https://connector-web.funnel.io/connect-config-schema.json",
							},
						},
					}),
					validate = { enable = true },
				},
			},
		})
		require("lspconfig")["gleam"].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end,
}
