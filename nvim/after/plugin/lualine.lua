-- local navic = require('nvim-navic')

require('lualine').setup {
  options = {
    section_separators = { left = "" },
    component_separators = { right = "|", left = "|" },
    theme = 'tokyonight',
  },
  sections = {
    lualine_c = {
      { "filename" },
      { "require'lsp-status'.status()" },
      { "require'break'.BreakNvim()" },
    },
    lualine_x = { 'encoding', 'filetype' },
  }
}
