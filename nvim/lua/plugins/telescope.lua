local send_to_filebrowser = function(prompt_bufnr)
	local action_state = require("telescope.actions.state")
	local actions = require("telescope.actions")
	local entry = action_state.get_selected_entry()
	local p = entry[1]
	local dir = p:match("(.*[/\\])")
	--actions.close()
	local cwd = vim.loop.cwd()
	local path = cwd .. "/" .. dir
	print(path)
	actions.close(prompt_bufnr)
	require("telescope").extensions.file_browser.file_browser({ path = path })
end

return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"smartpde/telescope-recent-files",
		"camgraff/telescope-tmux.nvim",
		"KadoBOT/nvim-spotify",
		"natecraddock/telescope-zf-native.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		{ "Lilja/telescope-swap-files" },
		--[[
		{
			dir = "~/code/telescope-dep-helper",
		},
		--]]
	},
	config = function()
		local actions = require("telescope.actions")
		local telescope = require("telescope")
		telescope.setup({
			defaults = {
				color_devicons = true,
				layout_strategy = "flex",
				file_ignore_patterns = { "node_modules" },
				-- Default configuration for telescope goes here:
				-- config_key = value,
				mappings = {
					i = { ["<esc>"] = actions.close },
				},
			},
			pickers = {
				find_files = {
					mappings = {
						i = {
							["<C-a>"] = send_to_filebrowser,
						},
						n = {
							["<C-a>"] = send_to_filebrowser,
						},
					},
				},
			},
		})

		telescope.load_extension("recent_files")
		telescope.load_extension("zf-native")
		telescope.load_extension("file_browser")
		telescope.load_extension("uniswapfiles")
		-- telescope.load_extension("dep-helper")

		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values

		function ConflictedList()
			local o = io.popen("git diff --name-only --diff-filter=U --relative")
			if o ~= nil then
				opts = opts or {}

				local result = o:read("*a")
				local resultPicker = {}
				for x in result:gmatch("([^\n]*)\n?") do
					table.insert(resultPicker, x)
				end

				pickers
					.new(opts, {
						prompt_title = "Git conflicts",
						finder = finders.new_table({
							results = resultPicker,
						}),
						sorter = conf.generic_sorter(opts),
					})
					:find()

				o:close()
			end
		end

		function WSSearch(files_or_search)
			local builtin = require("telescope.builtin")
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

				local find_command =
					{ "rg", "--ignore-file=" .. os.getenv("HOME") .. "/dotfiles/ripgrep/ignore", "--hidden", "--files" }
				if files_or_search == "files" then
					builtin.find_files({ hidden = true, cwd = ws, find_command = find_command })
				else
					builtin.live_grep({ hidden = true, cwd = ws })
				end
			end
		end

		vim.api.nvim_create_user_command("ConflictedList", ConflictedList, { desc = "Current git conflicts", nargs = 0 })
		vim.api.nvim_create_user_command("WSSearch", function()
			WSSearch("search")
		end, { desc = "Search in workspace of buffer", nargs = 0 })
		vim.api.nvim_create_user_command("WSFind", function()
			WSSearch("files")
		end, { desc = "Search files in workspace of buffer", nargs = 0 })
	end,
}
