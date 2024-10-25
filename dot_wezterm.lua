-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Solarized (light) (terminal.sexy)'

-- Configure the RHS scroll bar
config.enable_scroll_bar = true

-- Rendering Options
config.front_end = "WebGpu"
config.animation_fps = 60

-- Fonts
config.font = wezterm.font("CommitMono")
config.font_size = 15.0
config.line_height = 1.1

-- Window Opacity
config.macos_window_background_blur = 50
config.window_decorations = "RESIZE|MACOS_FORCE_ENABLE_SHADOW"
config.window_background_opacity = .85


-- Cursor setting
config.default_cursor_style = 'BlinkingBlock'

-- Initial window size and window decorators
config.initial_rows = 48
config.initial_cols = 140

-- Status Bar event handling
config.status_update_interval = 800

-- Tabs + colors
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 1000


wezterm.on("update-status", function(window, pane)
  -- Workspace name
  local stat = window:active_workspace()
  local stat_color = "#00a6b8"
  -- It's a little silly to have workspace name all the time
  -- Utilize this to display LDR or current key table name
  if window:active_key_table() then
    stat = window:active_key_table()
    stat_color = "#e18174"
  end
  if window:leader_is_active() then
    stat = "LDR"
    stat_color = "#d3ab80"
  end

  local basename = function(s)
    -- Nothing a little regex can't fix
    return string.gsub(s, "(.*[/\\])(.*)", "%2")
  end

  -- Current working directory
  local cwd = pane:get_current_working_dir()
  if cwd then
    cwd = cwd.file_path
  else
    cwd = ""
    end

  -- Current command
  local cmd = pane:get_foreground_process_name()
  -- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l)
  cmd = cmd and basename(cmd) or ""

  
  -- Left status (left of the tab line)
  window:set_left_status(wezterm.format({
    { Foreground = { Color = stat_color } },
    { Text = "  " },
    { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
    { Text = " |" },
  }))

  local bat = ''
  for _, b in ipairs(wezterm.battery_info()) do
    bat = string.format('%.0f%%', b.state_of_charge * 100)
  end

  -- Right status
  window:set_right_status(wezterm.format({
    -- use builtin wezterm nerdfonts to show cwd, cmd, and battery info
    { Foreground = { Color = "#ff9a00" } },
    { Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
    { Text = " | " },
    { Foreground = { Color = "#e5b687" } },
    { Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
    "ResetAttributes",
    { Text = " | " },
    { Text = wezterm.nerdfonts.md_battery_50 .. "  " .. bat },
    { Text = "  " },
  }))
end)

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)
	local LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider 
	local RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider 
	local edge_background = '#262626'
  local background = '#4c2f0a'
  local foreground = '#727272'

  if tab.is_active then
    background = '#ff9a00'
    foreground = '#000000'
  elseif hover then
    background = '#4c2f0a'
    foreground = '#909090'
  end

	local edge_foreground = background

	-- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  title = wezterm.truncate_right(title, max_width - 2)

	return wezterm.format({
		{ Attribute = { Underline = "Double" } },
		{ Attribute = { Italic = true } },
		{ Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " "..title.." " },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = RIGHT_ARROW },
	})
end)
-- Keys !!
	-- leader set to option/alt + Space. leader keymap accessible until timeout
config.leader = { key = " ", mods = "OPT", timeout_milliseconds = 1500}
	-- Config key tables for modal group editing
config.key_tables = {
  -- Resize the current active pane
  resize_pane = {
    { key = "h",      action = act.AdjustPaneSize { "Left", 1 } },
    { key = "j",      action = act.AdjustPaneSize { "Down", 1 } },
    { key = "k",      action = act.AdjustPaneSize { "Up", 1 } },
    { key = "l",      action = act.AdjustPaneSize { "Right", 1 } },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  },
}

config.keys = {
	{ key = ',', mods = 'LEADER', action = act.ActivateWindowRelative(1) },
	{ key = '.', mods = 'LEADER', action = act.ActivateWindowRelative(-1) },
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },
	{ key = "w", mods = "LEADER", action = act.ActivateKeyTable { name = "workspaces", one_shot = true } },
  --!! Pane keybindings !!-- 
  { key = "s",          mods = "LEADER",      action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "v",          mods = "LEADER",      action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "x",          mods = "LEADER",      action = act.CloseCurrentPane { confirm = false }},
  { key = "b",          mods = "LEADER",      action = act.ActivateWindowRelative(-1) },
  { key = "n",          mods = "LEADER",      action = act.ActivateWindowRelative(1) },
  { key = "h",          mods = "LEADER",      action = act.ActivatePaneDirection("Left") },
  { key = "j",          mods = "LEADER",      action = act.ActivatePaneDirection("Down") },
  { key = "k",          mods = "LEADER",      action = act.ActivatePaneDirection("Up") },
  { key = "l",          mods = "LEADER",      action = act.ActivatePaneDirection("Right") },
  { key = "q",          mods = "LEADER",      action = act.CloseCurrentPane { confirm = true } },
}
-- and finally, return the configuration to wezterm
return config
