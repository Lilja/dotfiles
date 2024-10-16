local function switch_case()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local word = vim.fn.expand('<cword>')
  local word_start = vim.fn.matchstrpos(vim.fn.getline('.'), '\\k*\\%' .. (col+1) .. 'c\\k*')[2]

  -- Detect camelCase
  if word:find('[a-z][A-Z]') then
    -- Convert camelCase to snake_case
    local snake_case_word = word:gsub('([a-z])([A-Z])', '%1_%2'):lower()
    vim.api.nvim_buf_set_text(0, line - 1, word_start, line - 1, word_start + #word, {snake_case_word})
  -- Detect snake_case
  elseif word:find('_[a-z]') then
    -- Convert snake_case to camelCase
    local camel_case_word = word:gsub('(_)([a-z])', function(_, l) return l:upper() end)
    vim.api.nvim_buf_set_text(0, line - 1, word_start, line - 1, word_start + #word, {camel_case_word})
  else
    print("Not a snake_case or camelCase word")
  end
end


function WSDirectory()
	local workspaces = vim.lsp.buf.list_workspace_folders()
	if #workspaces == 0 then
		print("No workspaces in this buffer")
		return
	elseif #workspaces >= 1 then
		local ws = workspaces[1]

		for _, workspace in ipairs(workspaces) do
			if workspace ~= ws then
				print("Multiple different workspaces. Exiting")
				return
			end
		end

		return ws
	end
end

return {

	{
		"mrjones2014/legendary.nvim",
		config = function()
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

			local IGNORE_FILE = os.getenv("HOME") .. "/dotfiles/ripgrep/ignore"

			-- vim.api.nvim_create_user_command("TeleSwap", teleSwap, { desc = "test", nargs = 0 })

			require("legendary").setup({
				include_builtin = false,
				keymaps = {
					{
						"<leader>le",
						":Legendary<CR>",
						description = "Open legendary, a table view of all keymaps, commands and functions",
					},
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
					{
						"<leader>gw",
						function()
							require("telescope.builtin").live_grep({
								hidden = true,
								additional_args = {
									"--ignore-file=" .. IGNORE_FILE,
								},
							})
						end,
						description = "Search in current dir/live grep",
					},
					{
						"<leader>gc",
						":Telescope grep_string hidden=true<CR>",
						description = "Search word under cursor in project",
					},
					{
						"<leader>ö",
						":Telescope find_files hidden=true find_command=rg,--ignore-file="
							.. IGNORE_FILE
							.. ",--hidden,--files<CR>",
						description = "Find files",
					},
					{ "<leader>rt", ":Telescope resume<CR>", description = "Resume telescope" },
					{ "<leader>rp", ":Telescope pickers<CR>", description = "List all cached pickers" },
					{
						"<leader>of",
						":lua require('telescope').extensions.recent_files.pick()<CR>",
						description = "Open recent files in telescope",
					},
					{
						"<leader>fb",
						":Telescope file_browser path=%:p:h select_buffer=true<CR>",
						description = "File browser in current directory",
					},
					-- Neoformat
					{ "<leader>f", ":Neoformat<CR>", description = "Format with Neoformat, guess the formatter." },
					-- Meta usage
					{
						"<leader>swap",
						"<cmd>Telescope uniswapfiles telescope_swap_files<CR>",
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
					{
						"<leader>dots",
						"<cmd>Telescope find_files hidden=true cwd=" .. dotDirPath(nil),
						description = "Find files in dot dir",
					},
					{
						"<leader>fb",
						":Telescope file_browser path=%:p:h select_buffer=true<CR>",
						description = "Opens file browser in current directory",
					},
					{
						"<leader>tp",
						":Telescope builtin include_extensions=true<CR>",
						description = "List all telescope pickers with third party extensions",
					},
					{
						"<leader>tt",
						":TodoTelescope<CR>",
						description = "Find todos in project",
					},
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
					{
						"<leader>a",
						":lua require('harpoon.mark').add_file()<CR>",
						description = "Harpoon-mark the current file+position",
					},
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
					--[[
					{
						"<C-f>",
						function()
							require("FTerm").run("tmux-sessionizer; exit 0")
						end,
						description = "Toggle tmux sessionizer",
					},
					--]]
					{
						"<C-F>",
						function()
							require("FTerm").run("tmux-sessionizer roots; exit 0")
						end,
						description = "Toggle tmux sessionizer by roots",
					},
					{
						"<leader>b",
						function()
							require("break").display_break()
						end,
						description = "debug break.nvim",
					},
					-- Switch case (camelCase <-> snake_case)
					{
						"<leader>h",
						switch_case,
						description = "Switch case (camelCase <-> snake_case)",
					},
					{
						"<leader>k",
						function ()
							switch_case()
							-- Now go to the next occurrence of the word, by pressing n
							vim.cmd([[ normal! n ]])
						end,
						description = "Switch case and go to next occurrence",
					},
					{
						"<C-t>",
						"<cmd>lua require('FTerm').toggle()<CR>",
						description = "Toggle FTerm",
						mode = { "n", "t" },
					}
				},
			})

			vim.cmd([[ :map Q <Nop> ]])
		end,
	},
}
