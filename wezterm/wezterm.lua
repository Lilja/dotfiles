local wezterm = require 'wezterm'


local open = io.open

local function read_file(path)
    local file = open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local path = os.getenv("HOME") .. "/dotfiles/real_hostname"
local fileContent = read_file(path)
local real_hostname = wezterm.hostname()
if fileContent ~= nil then
	real_hostname = string.gsub(fileContent, "%s+", "")
end

local prog = "/usr/local/bin/fish";
print(real_hostname)

if real_hostname == "Eriks-MBP"then
	prog = "/opt/homebrew/bin/fish"
end
if real_hostname == "DESKTOP-7DQK874" then
	prog = "wsl.exe"
end

return {
	default_prog = { prog },
	font = wezterm.font 'Fira Code',
	window_padding= {
				bottom = 0,
				left = "0.2cell",
				right = "0.2cell",
				top = "0.4cell",
	},
	send_composed_key_when_left_alt_is_pressed = true,
	color_scheme = "tokyonight",
	keys = {
		{
			key = 'r',
			mods = 'CMD|SHIFT',
			action = wezterm.action.ReloadConfiguration,
		},
	},
}
