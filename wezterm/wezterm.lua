local wezterm = require 'wezterm'


local prog = "/usr/local/bin/fish";

if wezterm.hostname() == "Eriks-MBP" or wezterm.hostname() == "DESKTOP-BL0DJVK.localdomain" then
	prog = "/opt/homebrew/bin/fish"
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
