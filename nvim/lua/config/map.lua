vim.keymap.set('n', ',f', vim.lsp.buf.formatting)
local nnoremap = function(lhs, rhs, silent)
	vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = silent })
end

nnoremap("<C-p>", '<cmd>Telescope find_files hidden=true<CR>')
nnoremap(",conf", '<cmd>Telescope find_files hidden=true cwd=~/dotfiles/nvim<CR>')
nnoremap(",i", '<cmd>Telescope live_grep hidden=true<CR>')
nnoremap(",cv", '<cmd>:e ~/.config/nvim/init.lua<CR>')
nnoremap(",map", '<cmd>:e ~/.config/nvim/lua/config/map.lua<CR>')

nnoremap(",fish", '<cmd>:e ~/.config/fish/config.fish<CR>')
-- local findWezTerm = function()
-- end
nnoremap(",wez", '<cmd>:e ~/.config/fish/config.fish<CR>')

nnoremap(",w", ":w<CR>")
nnoremap(",q", ":q<CR>")

vim.cmd[[ :map Q <Nop> ]]
