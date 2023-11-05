return {
	{
		"junegunn/goyo.vim",
		dependencies = {
			"preservim/vim-lexical",
			"junegunn/limelight.vim",
			"Lilja/cnotes.nvim"
			-- { dir = "/home/lilja/code/cnotes.nvim/" }
		},
		config = function()
			require("cnotes").setup({
				-- The ssh host in your ~/.ssh/config to connect to.
				sshHost = "solo",
				-- The directory to locally store journals
				localFileDirectory = os.getenv("HOME") .. "/Documents/journal",
				-- Binary
				--syncBinary = "cnotes-sftp-client",
				syncBinary = "cnotes-sftp-client",
				-- The path on the remote sFTP host of where you want to store files.
				destination = "/Personal/journal",
				-- When using :Journal, what kind of file type it will be.
				fileExtension = ".md",
			})
			local goyo_group = vim.api.nvim_create_augroup("GoyoGroup", { clear = true })
			vim.api.nvim_create_autocmd("User", {
				desc = "Hide lualine on goyo enter",
				group = goyo_group,
				pattern = "GoyoEnter",
				callback = function()
					require("lualine").hide()
				end,
			})
			vim.api.nvim_create_autocmd("User", {
				desc = "Show lualine after goyo exit",
				group = goyo_group,
				pattern = "GoyoLeave",
				callback = function()
					require("lualine").hide({ unhide = true })
				end,
			})

			vim.api.nvim_create_user_command("Journal", function(args)
				require('cnotes').startJournaling(args.args)
				vim.cmd("Goyo")
				vim.cmd("Limelight")
				vim.cmd("setlocal spell spelllang=sv")
			end, { desc = "Journal mode", nargs = "*" })
		end,
	},
}
