require('legendary').setup({
	keymaps = {
		-- Telescope
		{ '<leader>i', ':Telescope live_grep hidden=true<CR>', 'Search in current dir' },
		{ '<leader>ff', ':Telescope find_files hidden=true<CR>', 'Find files' },
		-- Neoformat
		{ '<leader>f', ':Neoformat<CR>', 'Format with Neoformat, guess the formatter.' },
		-- Meta usage
		{ '<leader>swap', '<cmd>Telescope find_files hidden=true cwd=' .. os.getenv('NVIM_SWAP_DIR') .. '<CR>',
			-- neovim files
			'Find swap files' },
		{ '<leader>conf', '<cmd>Telescope find_files hidden=true cwd=~/dotfiles/nvim<CR>', 'Find files in nvim dotfile dir' },
		{ '<leader><leader>conf', ':Telescope live_grep hidden=true<CR> cwd=~/dotfiles/nvim<CR>', 'Search in nvim dotfile dir' },
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
	}
})

vim.cmd [[ :map Q <Nop> ]]
