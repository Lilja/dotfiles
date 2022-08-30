local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lsp_flags = {
	-- This is the default in Nvim 0.7+
	debounce_text_changes = 150,
}
local navic = require("nvim-navic")
navic.setup {

}

local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

vim.o.updatetime = 250
OpenDiagFloat = function ()
  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(winid).zindex then
      return
    end
  end
  vim.diagnostic.open_float({focusable = false})
end

vim.cmd([[autocmd CursorHold <buffer> lua OpenDiagFloat()]])
vim.diagnostic.config({
	virtual_text = false,
})

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
	navic.attach(client, bufnr)

end

require('lspconfig')['pyright'].setup {
	on_attach = on_attach,
	flags = lsp_flags,
}

local lspconfig = require 'lspconfig'
local lspconfig_configs = require 'lspconfig.configs'
local lspconfig_util = require 'lspconfig.util'

local function on_new_config(new_config, new_root_dir)
	local function get_typescript_server_path(root_dir)
		local project_root = lspconfig_util.find_node_modules_ancestor(root_dir)
		return project_root and
		    (lspconfig_util.path.join(project_root, 'node_modules', 'typescript', 'lib', 'tsserverlibrary.js'))
		    or ''
	end

	if new_config.init_options
	    and new_config.init_options.typescript
	    and new_config.init_options.typescript.serverPath == ''
	then
		new_config.init_options.typescript.serverPath = get_typescript_server_path(new_root_dir)
	end
end

local volar_cmd = { 'vue-language-server', '--stdio' }
local volar_root_dir = lspconfig_util.root_pattern 'package.json'
--[[

lspconfig_configs.volar_api = {
	default_config = {
		on_attach = on_attach,
		cmd = volar_cmd,
		root_dir = volar_root_dir,
		on_new_config = on_new_config,
		filetypes = { 'vue' },
		-- If you want to use Volar's Take Over Mode (if you know, you know)
		--filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
		init_options = {
			typescript = {
				serverPath = ''
			},
			languageFeatures = {
				implementation = true, -- new in @volar/vue-language-server v0.33
				references = true,
				definition = true,
				typeDefinition = true,
				callHierarchy = true,
				hover = true,
				rename = true,
				renameFileRefactoring = true,
				signatureHelp = true,
				codeAction = true,
				workspaceSymbol = true,
				completion = {
					defaultTagNameCase = 'both',
					defaultAttrNameCase = 'kebabCase',
					getDocumentNameCasesRequest = false,
					getDocumentSelectionRequest = false,
				},
			}
		},
	}
}
lspconfig.volar_api.setup {}

lspconfig_configs.volar_doc = {
	default_config = {
		on_attach = on_attach,
		cmd = volar_cmd,
		root_dir = volar_root_dir,
		on_new_config = on_new_config,

		filetypes = { 'vue' },
		-- If you want to use Volar's Take Over Mode (if you know, you know):
		--filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
		init_options = {
			typescript = {
				serverPath = ''
			},
			languageFeatures = {
				implementation = true, -- new in @volar/vue-language-server v0.33
				documentHighlight = true,
				documentLink = true,
				codeLens = { showReferencesNotification = true },
				-- not supported - https://github.com/neovim/neovim/pull/15723
				semanticTokens = false,
				diagnostics = true,
				schemaRequestService = true,
			}
		},
	}
}
lspconfig.volar_doc.setup {}

lspconfig_configs.volar_html = {
	default_config = {
		on_attach = on_attach,
		cmd = volar_cmd,
		root_dir = volar_root_dir,
		on_new_config = on_new_config,

		filetypes = { 'vue' },
		-- If you want to use Volar's Take Over Mode (if you know, you know), intentionally no 'json':
		--filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
		init_options = {
			typescript = {
				serverPath = ''
			},
			documentFeatures = {
				selectionRange = true,
				foldingRange = true,
				linkedEditingRange = true,
				documentSymbol = true,
				-- not supported - https://github.com/neovim/neovim/pull/13654
				documentColor = false,
				documentFormatting = {
					defaultPrintWidth = 100,
				},
			}
		},
	}
}
lspconfig.volar_html.setup{}
--]]
require('lspconfig')["volar"].setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

--[[
require('lspconfig')["editorconfig"].setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
--]]
vim.lsp.set_log_level("debug")

local lua_language_server_location = {
				["Eriks-MBP"] = "/Downloads/lua-lang",
				["DESKTOP-7DQK874"] = "/Downloads/lua",
				["Eriks-MBP.localdomain"] = "/Downloads/lua-lang"
}
-- lspconfig.volar_html.setup {}

local sumneko_root_path = os.getenv("HOME") .. lua_language_server_location[vim.loop.os_gethostname()]
local sumneko_binary = sumneko_root_path .. "/bin/lua-language-server"
require('lspconfig')['sumneko_lua'].setup({
	cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
			completion = { enable = true, callSnippet = "Both" },
			diagnostics = {
				enable = true,
				globals = { 'vim', 'describe' },
				disable = { "lowercase-global" }
			},
			workspace = {
				library = {
					[vim.fn.expand('$VIMRUNTIME/lua')] = true,
					[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
					[vim.fn.expand('/usr/share/awesome/lib')] = true
				},
				-- adjust these two values if your performance is not optimal
				maxPreload = 2000,
				preloadFileSize = 1000
			}
		}
	},
	on_attach = on_attach
})

require('lspconfig')['tsserver'].setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require('lspconfig')['gopls'].setup {
	cmd = { "gopls", "serve" },
	filetypes = { "go", "gomod" },
	root_dir = lspconfig_util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
}






--[[
require("null-ls").setup({
    sources = {
        -- require("null-ls").builtins.diagnostics.eslint,
        require("null-ls").builtins.completion.spell,
    },
})
--]]
require("lspconfig")['eslint'].setup({ on_attach = on_attach })
