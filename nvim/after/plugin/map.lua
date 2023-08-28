local luasnip = require("luasnip")
local bufjump = require('bufjump')

vim.keymap.set({ "i", "s" }, '<C-k>', function ()
	if luasnip.expand_or_jumpable() then
			luasnip.expand_or_jump()
		end
end, { silent = true })

vim.keymap.set({ "i", "s" }, '<C-j>', function ()
	if luasnip.jumpable(-1) then
		luasnip.jump()
	end
end, { silent = true })

function dotDirPath(dir, file)
	if dir ~= nil then
		if file ~= nil then
			return os.getenv('DOTFILE_DIR') .. '/' .. dir .. '/' .. file .. "<CR>"
		end
		return os.getenv('DOTFILE_DIR') .. '/' .. dir .. "/<CR>"
	end
	return os.getenv('DOTFILE_DIR') .. "/<CR>"
end


require('legendary').setup({
	keymaps = {
		-- Bufjump, https://github.com/kwkarlwang/bufjump.nvim
		{ '<leader>o', function () bufjump.backward() end, 'Buffer back' },
		{ '<leader>i', function () bufjump.forward() end, 'Buffer forward' },
		-- Misc
		{ '<leader>p', '"_dP', 'Paste without deleting' },
		-- Telescope
		{ '<leader>gw', ':Telescope live_grep hidden=true<CR>', 'Search in current dir' },
		{ '<leader>ö', ':Telescope find_files hidden=true find_command=rg,--ignore-file='.. os.getenv("HOME") .. '/dotfiles/ripgrep/ignore,--hidden,--files<CR>', 'Find files' },
		{ '<leader>rt', ':Telescope resume<CR>', 'Resume telescope' },
		-- Neoformat
		{ '<leader>f', ':Neoformat<CR>', 'Format with Neoformat, guess the formatter.' },
		-- Meta usage
		{ '<leader>swap', '<cmd>Telescope find_files previewer=false hidden=true cwd=' .. os.getenv('NVIM_SWAP_DIR') .. '<CR>', 'Find swap files' },
		-- neovim files
		{ '<leader>conf', '<cmd>Telescope find_files hidden=true cwd=' .. dotDirPath('nvim'), 'Find files in nvim dotfile dir' },
		{ '<leader><leader>conf', '<cmd>Telescope live_grep hidden=true cwd=' .. dotDirPath(nil), 'Search in nvim dotfile dir' },
		-- dotfiles directory
		{ '<leader>dots', '<cmd>Telescope find_files hidden=true cwd=' .. dotDirPath(nil), 'Find files in dot dir' },
		-- Yoink
               {
                       "<leader>cc",
                       function()
                               local l = vim.fn.expand("%:t")

                               local out = ""
                               for i = 1, #l do
                                       local c = l:sub(i, i)
                                       if c == "." then
                                               break
                                       end

                                       out = out .. c
                               end
                               vim.fn.setreg("", out)
                       end,
                       "Yoink filename to register",
               },
		-- fish conf
		{ '<leader>fish', '<cmd>:e ' .. dotDirPath('fish' , 'config.fish'), 'Open fish config' },
		-- wez term conf
		{ '<leader>wez', '<cmd>:e ' .. dotDirPath('wezterm', 'wezterm.lua'), 'Open wezterm config' },
		-- Harpoon
		{ '<leader>a', ":lua require('harpoon.mark').add_file()<CR>", 'Harpoon-mark the current file+position' },
		{ '<leader>1', ":lua require('harpoon.ui').nav_file(1)<CR>", 'Harpoon navigate to 1st file' },
		{ '<leader>2', ":lua require('harpoon.ui').nav_file(2)<CR>", 'Harpoon navigate to 2nd file' },
		{ '<leader>3', ":lua require('harpoon.ui').nav_file(3)<CR>", 'Harpoon navigate to 3rd file' },
		{ '<leader>4', ":lua require('harpoon.ui').nav_file(4)<CR>", 'Harpoon navigate to 4th file' },
		{ '<leader>ha', ":lua require('harpoon.ui').toggle_quick_menu()<CR>", 'Harpoon menu' },
		-- Writes
		{ '<leader>w', ":w<CR>", 'Write to file' },
		{ '<leader>q', ":q<CR>", 'Quit file' },
		-- Luasnip
		{ '<leader><leader>s', function ()
			-- TODO: Figure out if we can use lua or something here...
			vim.cmd [[
				:source $HOME/dotfiles/nvim/after/plugin/lua/config/luasnip.lua
			]]
		end, 'Reload snippets' },
		-- Lsp-snip-reload
		-- Zellij+wezterm
		{ '<S-F8>', ':ZellijNavigateLeft<Cr>', 'Test' },
		{ '<S-F9>', ':ZellijNavigateDown<Cr>', 'Test' },
		{ '<S-F10>', ':ZellijNavigateUp<Cr>', 'Test' },
		{ '<S-F11>', ':ZellijNavigateRight<Cr>', 'Test' },
		{ '<A-h>', ':ZellijNavigateLeft<Cr>', 'Test' },
		{ '<A-j>', ':ZellijNavigateDown<Cr>', 'Test' },
		{ '<A-k>', ':ZellijNavigateUp<Cr>', 'Test' },
		{ '<A-l>', ':ZellijNavigateRight<Cr>', 'Test' },
	}
})

vim.cmd [[ :map Q <Nop> ]]
