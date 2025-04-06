--
-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
-- A GPU-accelerated cross-platform terminal emulator
-- https://wezfurlong.org/wezterm/


-- Pull in the wezterm API
local wezterm = require "wezterm"

-- This will hold the configuration
local config = wezterm.config_builder()

-- Config starts here
config = {
  -- Spawn a homebrew bash as a default shell
  default_prog = {
    "/usr/local/bin/bash",
  },

  -- Basic configuration
  automatically_reload_config = true,
  window_close_confirmation = "NeverPrompt",
  check_for_updates = false,
  initial_cols = 120,
  initial_rows = 32,

  -- Key bindings configuration
  keys = {
    -- Turn off the default CMD-m Hide action
    { key = "m", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    -- Navigate tabs in MacOS style
    { key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
    -- Split panes key bindings
    { key = "\"", mods = "CMD|SHIFT", action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = ":", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = "LeftArrow", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection "Left" },
    { key = "RightArrow", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection "Right" },
    { key = "UpArrow", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection "Up" },
    { key = "DownArrow", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection "Down" },
    -- Screen options
    { key = "a", mods = "CMD|SHIFT", action = wezterm.action.ToggleAlwaysOnTop },
    { key = "f", mods = "CMD|SHIFT", action = wezterm.action.ToggleFullScreen },
  },

  -- Colors configuration
  color_scheme = "Nord (Gogh)",
  colors = {
    foreground = "#A6C6DB", -- blue
    background = "#2E3337", -- black
    cursor_bg = "#A6C6DB", -- blue
    cursor_fg = "#7A7E7F", -- grey
    cursor_border = "#A6C6DB", -- blue
  },

  -- Appearance configuration
  cursor_blink_rate = 700,
  use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  enable_scroll_bar = false,
  adjust_window_size_when_changing_font_size = false,
  window_decorations = "RESIZE",
  default_cursor_style = "BlinkingBlock",
  font = wezterm.font("Fira Code"),
  font_size = 14,
  macos_window_background_blur = 0,
  background = {
    {
      source = { File = "/Users/" .. os.getenv("USER") .. "/.config/wezterm/bg.png" },
      width = "100%",
      height = "100%",
      opacity = 0.95,
    },
  },
  window_padding = {
    left = 5,
    right = 5,
    top = 5,
    bottom = 5,
  },
  hyperlink_rules = {
    -- Matches: a URL in parens: (URL)
    {
      regex = "\\((\\w+://\\S+)\\)",
      format = "$1",
      highlight = 1,
    },
    -- Matches: a URL in brackets: [URL]
    {
      regex = "\\[(\\w+://\\S+)\\]",
      format = "$1",
      highlight = 1,
    },
    -- Matches: a URL in curly braces: {URL}
    {
      regex = "\\{(\\w+://\\S+)\\}",
      format = "$1",
      highlight = 1,
    },
    -- Matches: a URL in angle brackets: <URL>
    {
      regex = "<(\\w+://\\S+)>",
      format = "$1",
      highlight = 1,
    },
    -- Then handle URLs not wrapped in brackets
    {
      regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
      format = "$1",
      highlight = 1,
    },
    -- Implicit mailto link
    {
      regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
      format = "mailto:$0",
    },
  },
}
-- Config ends here

-- Return the final configuration to wezterm
return config
