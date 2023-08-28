require("telescope").setup({
	defaults = {
		color_devicons = true,
		file_ignore_patterns = { "node_modules" },
		-- Default configuration for telescope goes here:
		-- config_key = value,
		mappings = {},
	},
})

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

vim.api.nvim_create_user_command("ConflictedList", ConflictedList, { desc = "Current git conflicts", nargs = 0 })
