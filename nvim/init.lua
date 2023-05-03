local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

vim.cmd([[
set shell=/bin/bash
let g:python3_host_prog = expand('$XDG_CACHE_HOME/neovim/neovim-py/bin/python')
]])
--let g:node_host_prog = trim(system("echo $nvm_data/v18.12.1/bin/node"))

require("packer").startup(function(use)
	use("benknoble/vim-synstax")
	use({ "wbthomason/packer.nvim" })
	use("neovim/nvim-lspconfig") -- Configurations for Nvim LSP
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-nvim-lua")
	use("hrsh7th/cmp-buffer")
	use({
		"L3MON4D3/LuaSnip",
		after = "nvim-cmp",
	})
	use({ "saadparwaiz1/cmp_luasnip" })
	use("imsnif/kdl.vim")
	use("ray-x/lsp_signature.nvim")
	use("onsails/lspkind.nvim")
	use({"hrsh7th/nvim-cmp"})
	use("dag/vim-fish")
	use("mhinz/vim-startify")
	use({
		"lewis6991/gitsigns.nvim",
		-- tag = 'release' -- To use the latest release
	})
	use("kyazdani42/nvim-web-devicons")
	use({
		"nvim-lualine/lualine.nvim",
		requires = {
			"kyazdani42/nvim-web-devicons",
			opt = true,
		},
	})

	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
		config = function()
		end,
	})

	use("folke/tokyonight.nvim")
	use("EdenEast/nightfox.nvim")
	use("andersevenrud/nordic.nvim")
	use({
		"catppuccin/nvim",
		as = "catppuccin",
	})

	use("nvim-treesitter/playground")
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})
	use({ "mrjones2014/legendary.nvim" })

	use("nvim-treesitter/nvim-treesitter-context")
	use("gpanders/editorconfig.nvim")
	-- use 'othree/javascript-libraries-syntax.vim'
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	})
	use({
		"metakirby5/codi.vim",
		config = function() end,
	})
	use("pangloss/vim-javascript")
	use("jose-elias-alvarez/null-ls.nvim")
	use({
		"SmiteshP/nvim-navic",
		requires = "neovim/nvim-lspconfig",
	})

	use({
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	})

	use("nvim-lua/lsp-status.nvim")
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({})
		end,
	})
	
	use("mattn/emmet-vim")
	use("tpope/vim-eunuch")

	use "sbdchd/neoformat"
	-- use("folke/which-key.nvim")
	use("ThePrimeagen/harpoon")
	use({
		-- "lilja/lsp-luasnip",
		"Lilja/lsp-luasnip",
		-- requires = {"L3MON4D3/LuaSnip", "neovim/nvim-lspconfig"},
	})
	-- use 'numToStr/prettierrc.nvim'

	-- use '~/code/zellij.nvim'
	use 'yegappan/mru'
	use {
		"williamboman/mason.nvim",
		config = function ()
			require('mason').setup({})
		end
	}
	use({
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({})
		end,
	})
	use({
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"lua-language-server", -- sumneko_lua
					"rust-analyzer",
					"tailwindcss-language-server", -- tailwindcss
					"typescript-language-server", -- tsserver
					"dockerfile-language-server", -- dockerls
					"gopls",
					"pyright",
					"vue-language-server", -- volar
					"prettier",
					"black",
				},
			})
		end,
	})
	use 'vimpostor/vim-tpipeline'
	
	use 'ThePrimeagen/vim-be-good'
	use ({
		'windwp/nvim-ts-autotag',
		config = function()
			require'nvim-treesitter.configs'.setup {
				autotag = {
					enable = true,
				}
			}
		end
	})
	use 'Lilja/shevim'
	use "davidosomething/format-ts-errors.nvim"
	use {
    'KadoBOT/nvim-spotify',
    requires = 'nvim-telescope/telescope.nvim',
    config = function()
        local spotify = require'nvim-spotify'

        spotify.setup {
            -- default opts
            status = {
                update_interval = 10000, -- the interval (ms) to check for what's currently playing
                format = '%s %t by %a' -- spotify-tui --format argument
            }
        }
    end,
    run = 'make'
}
	if packer_bootstrap then
		require("packer").sync()
	end
end)

vim.cmd("filetype plugin on")

vim.g.mapleader = " "
-- If no editorconfig, then use default config
-- prettier has 2 default spaces if no config otherwise.
vim.cmd[[
if !exists('b:editorconfig')
	set shiftwidth=4
	set expandtab
endif
]]
vim.wo.relativenumber = true
vim.wo.number = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 2
vim.o.cursorline = true
vim.cmd("highlight CursorLineNR guifg=#e5c890")
vim.cmd([[
    autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]])
vim.o.termguicolors = true

vim.opt.listchars = {
	tab = "» ",
	extends = "⟩",
	precedes = "⟨",
	trail = "·",
}
vim.opt.list = true
vim.cmd([[
  set tabstop=2
]])

-- Fix when winbar in a release
-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"
	-- ensure_installed = {  },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
require("treesitter-context").setup({
	enable = true,
})
vim.cmd([[ 
  let g:startify_change_to_dir = 0
]])
vim.opt.directory = os.getenv("NVIM_SWAP_DIR")
vim.opt.undodir = os.getenv("NVIM_UNDO_DIR")
vim.opt.undofile = true

function recompile()
  if vim.bo.buftype == "" then
    if vim.fn.exists ":LspStop" ~= 0 then
      vim.cmd "LspStop"
    end

    for name, _ in pairs(package.loaded) do
      if name:match "^user" then
        package.loaded[name] = nil
      end
    end

    dofile(vim.env.MYVIMRC)
    vim.cmd "PackerCompile"
    vim.notify("Wait for Compile Done", vim.log.levels.INFO)
  else
    vim.notify("Not available in this window/buffer", vim.log.levels.INFO)
  end
end
function GenerateEditorConfig()
		local workspaces = vim.lsp.buf.list_workspace_folders()
		if (#workspaces == 0) then
			print("No workspaces in this buffer")
		elseif (#workspaces > 1) then
			local workspace = workspaces[1]
			local filename = workspace .. "/.editorconfig"
			local f = io.open(filename,"r")
			if f ~= nil then
				-- File exists, just open it.
				io.close(f)
				vim.cmd('e ' .. filename)
				return
			end
			vim.cmd('e ' .. filename)
			local s = {
				"[*]",
				"indent_size = 2",
				"indent_style = space"
			}

      vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, s);
			-- Restart gpanders/editorconfig
			require('editorconfig').config()
		end
end
vim.api.nvim_create_user_command("Recompile", function() recompile() end, {})
vim.api.nvim_create_user_command("GenerateEditorConfig", function() GenerateEditorConfig() end, {})
vim.cmd[[
set timeout timeoutlen=200
]]
