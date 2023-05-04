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


require('legendary').setup({
	keymaps = {
		-- Bufjump, https://github.com/kwkarlwang/bufjump.nvim
		{ '<leader>o', function () bufjump.backward() end, 'Buffer back' },
		{ '<leader>i', function () bufjump.forward() end, 'Buffer forward' },
		-- Misc
		{ '<leader>p', '"_dP', 'Paste without deleting' },
		-- Telescope
		{ '<leader>i', ':Telescope live_grep hidden=true<CR>', 'Search in current dir' },
		{ '<leader>ö', ':Telescope find_files hidden=true find_command=rg,--ignore-file='.. os.getenv("HOME") .. '/dotfiles/ripgrep/ignore,--hidden,--files<CR>', 'Find files' },
		{ '<leader>rt', ':Telescope resume<CR>', 'Resume telescope' },
		-- Neoformat
		{ '<leader>f', ':Neoformat<CR>', 'Format with Neoformat, guess the formatter.' },
		-- Meta usage
		{ '<leader>swap', '<cmd>Telescope find_files hidden=true cwd=' .. os.getenv('NVIM_SWAP_DIR') .. '<CR>', 'Find swap files' },
		-- neovim files
		{ '<leader>conf', '<cmd>Telescope find_files hidden=true cwd=~/dotfiles/nvim<CR>', 'Find files in nvim dotfile dir' },
		{ '<leader><leader>conf', '<cmd>Telescope live_grep hidden=true<CR> cwd=~/dotfiles/nvim<CR>', 'Search in nvim dotfile dir' },
		-- fish conf
		{ '<leader>fish', '<cmd>:e ~/.config/fish/config.fish<CR>', 'Open fish config' },
		-- wez term conf
		{ '<leader>wez', '<cmd>:e ~/dotfiles/wezterm/wezterm.lua<CR>', 'Open wezterm config' },
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
			vim.cmd [[
				:source $HOME/dotfiles/nvim/after/plugin/lua/config/luasnip.lua
			]]
		end, 'Reload snippets' },
		-- Lsp-snip-reload
	}
})

vim.cmd [[ :map Q <Nop> ]]
