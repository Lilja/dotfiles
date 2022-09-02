local util = require('lspconfig/util')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lsp_flags = {
	-- This is the default in Nvim 0.7+
	debounce_text_changes = 150,
}
local navic = require("nvim-navic")
navic.setup {}

local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	vim.o.updatetime = 250
	OpenDiagFloat = function()
		for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.api.nvim_win_get_config(winid).zindex then
				return
			end
		end
		vim.diagnostic.open_float({ focusable = false })
	end

	vim.cmd([[autocmd CursorHold <buffer> lua OpenDiagFloat()]])
	vim.diagnostic.config({
		virtual_text = false,
	})

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
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


local function get_python_path(workspace)
	-- Use activated virtualenv.
	if vim.env.VIRTUAL_ENV then
		return util.path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
	end

	-- Find and use virtualenv from pipenv in workspace directory.
	local pipenvMatch = vim.fn.glob(util.path.join(workspace, 'Pipfile'))
	if pipenvMatch ~= '' then
		local venv = vim.fn.trim(vim.fn.system('PIPENV_PIPFILE=' .. pipenvMatch .. ' pipenv --venv'))
		return util.path.join(venv, 'bin', 'python')
	end

	-- Find and use virtualenv from poetry in workspace directory.
	local poetryMatch = vim.fn.glob(util.path.join(workspace, 'poetry.lock'))
	if poetryMatch ~= '' then
		local venv = vim.fn.trim(vim.fn.system('poetry env info -p'))
		return util.path.join(venv, 'bin', 'python')
	end

	-- Fallback to system Python.
	return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

require('lspconfig')['pyright'].setup {
	on_attach = on_attach,
	before_init = function(_, config)
		config.settings.python.pythonPath = get_python_path(config.root_dir)
	end,
	flags = lsp_flags,
}

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

local HOME = os.getenv("HOME")
local lua_language_server_location = {
	["Eriks-MBP"] = HOME .. "/Downloads/lua",
	["DESKTOP-7DQK874"] = HOME .. "/Downloads/lua",
	["Eriks-MBP.localdomain"] = HOME .. "/Downloads/lua-lang",
}
-- lspconfig.volar_html.setup {}

local sumneko_root_path = lua_language_server_location[vim.loop.os_gethostname()]
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
	root_dir = util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
}
require('lspconfig')['gopls'].setup {
	on_attach = on_attach,
	capabilities = capabilities,
}

