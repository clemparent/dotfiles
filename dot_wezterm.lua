-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

-- Import tabline plugin
local tabline_path = "/Users/cparent/.config/wezterm/plugins/tabline.wez"
local tabline = wezterm.plugin.require(tabline_path)


-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Catppuccin Frappe'

-- Configure the RHS scroll bar
config.enable_scroll_bar = true

-- Rendering Options
config.front_end = "WebGpu"
config.animation_fps = 60

-- Fonts
config.font = wezterm.font("CommitMono")
config.font_size = 13.5
config.line_height = 1.1

-- Window Opacity
config.macos_window_background_blur = 50
config.window_decorations = "RESIZE|MACOS_FORCE_ENABLE_SHADOW"
config.window_background_opacity = .85


-- Cursor setting
config.default_cursor_style = 'BlinkingBlock'

-- Initial window size and window decorators
config.initial_rows = 60
config.initial_cols = 200

-- Status Bar event handling
config.status_update_interval = 800

-- Tabs + colors
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 1000

-- Tabline config
tabline.setup({
  options = {
    icons_enabled = true,
    theme = 'Catppuccin Mocha',
    tabs_enabled = true,
    theme_overrides = {},
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
  },
  sections = {
    tabline_a = { 'workspace' },
    tabline_b = { ' ' },
    tab_active = {
      'index',
      { 'parent', padding = 0 },
      '/',
      { 'cwd', padding = { left = 0, right = 1 } },
      { 'zoomed', padding = 0 },
    },
    tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
    tabline_x = { 'ram', 'cpu' },
    tabline_y = { { 'datetime', style='%b %d %l:%M%P', }, 'battery' },
    tabline_z = { 'domain' },
  },
  extensions = {},
})
tabline.setup()

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
