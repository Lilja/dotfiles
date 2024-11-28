vim.g.mapleader = " "
vim.cmd([[
set shell=/bin/bash
let g:python3_host_prog = expand('$XDG_CACHE_HOME/neovim/neovim-py/bin/python')
let g:neoformat_try_node_exe = 1
]])
--let g:node_host_prog = trim(system("echo $nvm_data/v18.12.1/bin/node"))

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", { rocks = { enabled = false } })

vim.cmd("filetype plugin on")

-- If no editorconfig, then use default config
-- prettier has 2 default spaces if no config otherwise.
vim.cmd([[
if !exists('b:editorconfig')
	set shiftwidth=4
	set expandtab
endif
]])
-- Set makefile to use tabs
vim.cmd([[
autocmd BufRead,BufNewFile Makefile setlocal noexpandtab
]])
vim.wo.relativenumber = true
vim.wo.number = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 2
vim.o.cursorline = true
vim.cmd("highlight CursorLineNR guifg=#e5c890")
vim.cmd([[
    autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]])
vim.o.termguicolors = true
vim.o.colorcolumn = "120"

vim.opt.listchars = {
	tab = "» ",
	extends = "⟩",
	precedes = "⟨",
	trail = "·",
	nbsp = "␣",
}
vim.opt.list = true
vim.cmd([[
  set tabstop=2
]])

vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"



vim.cmd([[
  let g:startify_change_to_dir = 0
]])
vim.opt.directory = os.getenv("NVIM_SWAP_DIR")
vim.opt.undodir = os.getenv("NVIM_UNDO_DIR")
vim.opt.undofile = true

function GenerateEditorConfig()
	local workspaces = vim.lsp.buf.list_workspace_folders()
	if #workspaces == 0 then
		print("No workspaces in this buffer")
	elseif #workspaces >= 1 then
		local workspace = workspaces[1]
		local filename = workspace .. "/.editorconfig"
		local f = io.open(filename, "r")
		if f ~= nil then
			-- File exists, just open it.
			io.close(f)
			vim.cmd("e " .. filename)
			return
		end
		vim.cmd("e " .. filename)
		local s = {
			"[*]",
			"indent_size = 2",
			"indent_style = space",
		}

		vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, s)
		-- Restart gpanders/editorconfig
		require("editorconfig").config()
	end
end
function UidV4()
	local Job = require("plenary.job")
	Job:new({
		command = "curl",
		args = { "-s", "https://www.uuidgenerator.net/api/version4" },
		on_exit = vim.schedule_wrap(function(j, return_val)
			local output = j:result()[1]
			vim.api.nvim_call_function("setreg", { '""', output })
			print("Done")
		end),
	}):start()
end
function makeId()
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
	-- Bump this number if collisions are found
	local idLength = 8
	local id = {}
	for i = 1, idLength do
		-- Grab a random character from the alphabet
		local randomIndex = math.random(1, #alphabet)
		table.insert(id, alphabet:sub(randomIndex, randomIndex))
	end
	return table.concat(id)
end
vim.api.nvim_create_user_command("UidV4", function()
	UidV4()
end, {})
vim.api.nvim_create_user_command("MakeId", function()
	local id = makeId()
	vim.api.nvim_call_function("setreg", { '""', id })
end, {})
vim.api.nvim_create_user_command("GenerateEditorConfig", function()
	GenerateEditorConfig()
end, {})
vim.cmd([[
set timeout timeoutlen=500
let g:lexical#spelllang = ['sv']
]])

vim.cmd [[
	autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0
]]
