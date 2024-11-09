local wezterm = require("wezterm")

local open = io.open

local function read_file(path)
	local file = open(path, "rb") -- r read mode and b binary mode
	if not file then
		return nil
	end
	local content = file:read("*a") -- *a or *all reads the whole file
	file:close()
	return content
end

-- USERPROFILE for Windows
local home = os.getenv("HOME") or os.getenv("USERPROFILE")
local path = home .. "/dotfiles/real_hostname"
local fileContent = read_file(path)
local real_hostname = wezterm.hostname()
if fileContent ~= nil then
	real_hostname = string.gsub(fileContent, "%s+", "")
end

local prog = "/usr/local/bin/fish"

if real_hostname == "Eriks-MBP" then
	prog = "/opt/homebrew/bin/fish"
end
if real_hostname == "DESKTOP-7DQK874" then
	prog = "wsl.exe"
end
if real_hostname == "lilyflower" then
	prog = "/home/linuxbrew/.linuxbrew/bin/fish"
end

local c = {}
if wezterm.config_builder then
	c = wezterm.config_builder()
	c:set_strict_mode(true)
end
c.color_scheme = "Catppuccin Mocha"
c.send_composed_key_when_left_alt_is_pressed = true
c.window_padding = {
	bottom = 0,
	left = "0.2cell",
	right = "0.2cell",
	top = "0.4cell",
}
c.default_prog = { prog }
if real_hostname == "lilyflower" then
	c.font = wezterm.font("FiraCode Nerd Font")
else
	c.font = wezterm.font("Fira Code")
end
local act = wezterm.action
c.hide_tab_bar_if_only_one_tab = true

c.keys = {
	{
		key = "1",
		mods = "CMD",
		action = act.SendKey({
			key = "1",
			mods = "ALT",
		}),
	},
	{
		key = "2",
		mods = "CMD",
		action = act.SendKey({
			key = "2",
			mods = "ALT",
		}),
	},
	{
		key = "3",
		mods = "CMD",
		action = act.SendKey({
			key = "3",
			mods = "ALT",
		}),
	},
	{
		key = "4",
		mods = "CMD",
		action = act.SendKey({
			key = "4",
			mods = "ALT",
		}),
	},
	{
		key = "5",
		mods = "CMD",
		action = act.SendKey({
			key = "5",
			mods = "ALT",
		}),
	},
  { key = "Insert", mods = "SHIFT", action = act.PasteFrom("Clipboard") },
}

function make_mouse_binding(dir, streak, button, mods, action)
	return {
		event = { [dir] = { streak = streak, button = button } },
		mods = mods,
		action = action,
	}
end

return c
