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



local c = {}
if wezterm.config_builder then
	c = wezterm.config_builder()
	c:set_strict_mode(true)
end
c.color_scheme = "tokyonight"
c.send_composed_key_when_left_alt_is_pressed = true
c.window_padding = {
	bottom = 0,
	left = "0.2cell",
	right = "0.2cell",
	top = "0.4cell",
}
c.default_prog = { prog }
c.font = wezterm.font("Fira Code")
local act = wezterm.action
--[[
c.leader = {
	key = "w",
	mods = "CTRL",
	timeout_milliseconds = math.maxinteger,
}
--]]
function lol(direction, pane)
	--print(os.getenv("VIMRUNTIME") .. ". direction " .. direction)
  local name = pane:get_tty_name()
  print(name)
  wezterm.log_info('Hello from callback!')
  wezterm.log_info(name)
  local map = {
    Left = "F8",
    Down = "F9",
    Up  = "F10",
    Right = "F11",
  }
  if os.getenv("VIMRUNTIME") then
      act.SendKey({
          key = map[direction],
          mods = "SHIFT"
      })
      --[[act.SendString(":ZellijNavigate" .. direction .. "\
")--]]
  else
      act.ActivatePaneDirection(direction)
  end
end


c.keys = {
    --[[
	{
		key = "g",
		mods = "CTRL",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "h",
		mods = "LEADER",
    action = wezterm.action_callback(function (win, pane)
        wezterm.log_info('Hello from callback!')
        wezterm.log_info(win)
        wezterm.log_info(pane)
        wezterm.log_info(pane:pane_id())
        local info = pane:get_foreground_process_info()
        wezterm.log_info("this")
        wezterm.log_info(info)
        lol("Left", pane)
    end)
	},
	{
		key = "j",
		mods = "LEADER",
    action = wezterm.action_callback(function (win, pane)
        lol("Down", pane)
    end)
	},
	{
		key = "k",
		mods = "LEADER",
    action = wezterm.action_callback(function (win, pane)
        lol("Up", pane)
    end)
	},
	{
		key = "l",
		mods = "LEADER",
    action = wezterm.action_callback(function (win, pane)
        wezterm.log_info('Hello from callback!!!!')
        wezterm.log_info(win)
        wezterm.log_info(pane)
        lol("Right", pane)
    end)
	},
	{
		key = "v",
		mods = "LEADER",
		action = act.SendString(":vsp\
    "),
	},
  {
		key = "s",
		mods = "LEADER",
		action = act.SendString(":sp\
    "),
	},
  --]]
}

return c
