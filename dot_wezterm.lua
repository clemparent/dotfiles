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
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE|MACOS_FORCE_ENABLE_SHADOW"
config.window_background_opacity = .85

-- Window padding
config.window_padding = {
    top = 5,
}

-- Cursor setting
config.default_cursor_style = 'BlinkingBlock'

-- Initial window size and window decorators
config.initial_rows = 48
config.initial_cols = 140

-- Status Bar event handling
config.status_update_interval = 800

-- Tabs + colors
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.tab_max_width = 1000



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
  -- Pick from a set of workspaces
  workspaces = {
    { key = "d",      action = act.SwitchToWorkspace{ name =  "default" } },
    { key = "c",      action = act.SwitchToWorkspace{ name =  "coding", } },
    { key = "m",      action = act.SwitchToWorkspace{ name =  "monitoring", spawn = { args = {"/opt/homebrew/bin/btop"}, } } },
    { key = "i",      action = act.ShowLauncherArgs{flags = "FUZZY|WORKSPACES"} },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  }
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
