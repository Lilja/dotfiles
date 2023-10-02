local luasnip = require("luasnip")
local bufjump = require("bufjump")

vim.keymap.set({ "i", "s" }, "<C-k>", function()
	if luasnip.expand_or_jumpable() then
		luasnip.expand_or_jump()
	end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-j>", function()
	if luasnip.jumpable(-1) then
		luasnip.jump()
	end
end, { silent = true })

function dotDirPath(dir, file)
	if dir ~= nil then
		if file ~= nil then
			return os.getenv("DOTFILE_DIR") .. "/" .. dir .. "/" .. file .. "<CR>"
		end
		return os.getenv("DOTFILE_DIR") .. "/" .. dir .. "/<CR>"
	end
	return os.getenv("DOTFILE_DIR") .. "/<CR>"
end



-- vim.api.nvim_create_user_command("TeleSwap", teleSwap, { desc = "test", nargs = 0 })

require("legendary").setup({
	keymaps = {
		-- Bufjump, https://github.com/kwkarlwang/bufjump.nvim
		{
			"<leader>o",
			function()
				bufjump.backward()
			end,
			description = "Buffer back",
		},
		{
			"<leader>i",
			function()
				bufjump.forward()
			end,
			description = "Buffer forward",
		},
		-- Misc
		{ "<leader>p", '"_dP', description = "Paste without deleting" },
		-- Telescope
		{ "<leader>gw", ":Telescope live_grep hidden=true<CR>", description = "Search in current dir" },
		{
			"<leader>ö",
			":Telescope find_files hidden=true find_command=rg,--ignore-file="
				.. os.getenv("HOME")
				.. "/dotfiles/ripgrep/ignore,--hidden,--files<CR>",
			description = "Find files",
		},
		{ "<leader>rt", ":Telescope resume<CR>", description = "Resume telescope" },
		-- Neoformat
		{ "<leader>f", ":Neoformat<CR>", description = "Format with Neoformat, guess the formatter." },
		-- Meta usage
		{
			"<leader>swap",
			"<cmd>Telescope find_files previewer=false hidden=true cwd=" .. os.getenv("NVIM_SWAP_DIR") .. "<CR>",
			description = "Find swap files",
		},
		-- neovim files
		{
			"<leader>conf",
			"<cmd>Telescope find_files hidden=true cwd=" .. dotDirPath("nvim"),
			description = "Find files in nvim dotfile dir",
		},
		{
			"<leader><leader>conf",
			"<cmd>Telescope live_grep hidden=true cwd=" .. dotDirPath(nil),
			description = "Search in nvim dotfile dir",
		},
		-- dotfiles directory
		{ "<leader>dots", "<cmd>Telescope find_files hidden=true cwd=" .. dotDirPath(nil), description = "Find files in dot dir" },
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
			description = "Yoink filename to register",
		},
		-- fish conf
		{ "<leader>fish", "<cmd>:e " .. dotDirPath("fish", "config.fish"), description = "Open fish config" },
		-- wez term conf
		{ "<leader>wez", "<cmd>:e " .. dotDirPath("wezterm", "wezterm.lua"), description = "Open wezterm config" },
		-- Harpoon
		{ "<leader>a", ":lua require('harpoon.mark').add_file()<CR>", description = "Harpoon-mark the current file+position" },
		{ "<leader>1", ":lua require('harpoon.ui').nav_file(1)<CR>", description = "Harpoon navigate to 1st file" },
		{ "<leader>2", ":lua require('harpoon.ui').nav_file(2)<CR>", description = "Harpoon navigate to 2nd file" },
		{ "<leader>3", ":lua require('harpoon.ui').nav_file(3)<CR>", description = "Harpoon navigate to 3rd file" },
		{ "<leader>4", ":lua require('harpoon.ui').nav_file(4)<CR>", description = "Harpoon navigate to 4th file" },
		{ "<leader>ha", ":lua require('harpoon.ui').toggle_quick_menu()<CR>", description = "Harpoon menu" },
		-- Writes
		{ "<leader>w", ":w<CR>", description = "Write to file" },
		{ "<leader>q", ":q<CR>", description = "Quit file" },
		-- Luasnip
		{
			"<leader><leader>s",
			function()
				-- TODO: Figure out if we can use lua or something here...
				vim.cmd([[
				:source $HOME/dotfiles/nvim/after/plugin/lua/config/luasnip.lua
			]])
			end,
			description = "Reload snippets",
		},
		-- Lsp-snip-reload
		{
			"<C-f>",
			function()
				require("FTerm").run("tmux-sessionizer; exit 0")
			end,
			description = "Toggle tmux sessionizer",
		},
	},
})

vim.cmd([[ :map Q <Nop> ]])
