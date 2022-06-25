vim.keymap.set('n', ',f', vim.lsp.buf.formatting)
local nnoremap = function(lhs, rhs, silent)
	vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = silent })
end

nnoremap("<C-p>", '<cmd>Telescope find_files<CR>')
nnoremap(",i", '<cmd>Telescope live_grep<CR>')
nnoremap(",cv", '<cmd>:e ~/.config/nvim/init.lua<CR>')

