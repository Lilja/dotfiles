local wezterm = require 'wezterm'


local prog = "/usr/local/bin/fish";

if wezterm.hostname() == "Eriks-MBP" or wezterm.hostname() == "DESKTOP-BL0DJVK.localdomain" then
	prog = "/opt/homebrew/bin/fish"
end

return {
	default_prog = { prog },
	font = wezterm.font 'Fira Code',
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
