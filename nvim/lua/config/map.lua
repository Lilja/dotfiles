vim.keymap.set('n', ',f', vim.lsp.buf.formatting)
local nnoremap = function(lhs, rhs, silent)
	vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = silent })
end

local telescope_builtin = require('telescope.builtin')
local state = false
function telescope_helper()
				if state then
								telescope_builtin.resume({ mode = "n"})
				else
								state = true
								telescope_builtin.live_grep({ mode = "n"})
				end

end

local root = ""

function find_workspace_files()
				if root == "" then
								local cwd = vim.fn.getcwd()

				end
end

-- Telescope
vim.keymap.set('n', ",wf", find_workspace_files)
nnoremap(",ff", '<cmd>Telescope find_files hidden=true<CR>')
vim.keymap.set('n', ',fw', telescope_helper)
nnoremap(",conf", '<cmd>Telescope find_files hidden=true cwd=~/dotfiles/nvim<CR>')
nnoremap(",i", '<cmd>Telescope live_grep hidden=true<CR>')
nnoremap(",*", '<cmd>Telescope grep_string<CR>')

-- Fancy opens
nnoremap(",cv", '<cmd>:e ~/.config/nvim/init.lua<CR>')
nnoremap(",map", '<cmd>:e ~/.config/nvim/lua/config/map.lua<CR>')
nnoremap(",fish", '<cmd>:e ~/.config/fish/config.fish<CR>')
nnoremap(",wez", '<cmd>:e ~/.config/fish/config.fish<CR>')

-- harpoon mark
nnoremap(",a", ":lua require('harpoon.mark').add_file()<CR>")
-- harpoon next
local hui = require('harpoon.ui')
vim.keymap.set('n', ',n', function() hui.nav_next(); end)


nnoremap(",w", ":w<CR>")
nnoremap(",q", ":q<CR>")

vim.cmd[[ :map Q <Nop> ]]
