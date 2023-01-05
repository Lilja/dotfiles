--[[
require("catppuccin").setup({
  integrations = {
    treesitter = true,
    telescope = true,
  }
})
vim.g.catppuccin_flavour = "frappe" -- latte, frappe, macchiato, mocha
vim.cmd [[colorscheme catppuccin]]
--]]

--[[
vim.g.tokyonight_italic_keywords = false
vim.cmd[[
  colorscheme tokyonight
]]
--]]
vim.cmd("colorscheme nightfox")
