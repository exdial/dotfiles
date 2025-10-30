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
  check_for_updates = true,
  initial_cols = 120,
  initial_rows = 32,

  -- Colors configuration high-contrast-but-soft (Tokyo Night inspired)
  colors = {
    foreground = "#C8DCEF",
    background = "#0F1724",
    cursor_bg = "#7AA2F7",
    cursor_fg = "#0F1724",
    cursor_border = "#7AA2F7",
    selection_bg = "#23324A",
    selection_fg = "#C8DCEF",
    scrollbar_thumb = "#2A3346",

    -- ANSI colors (normal)
    ansi = {
      "#0F1724", -- black
      "#BF616A", -- red
      "#A3BE8C", -- green
      "#EBCB8B", -- yellow
      "#7AA2F7", -- blue
      "#B48EAD", -- magenta
      "#8FBCBB", -- cyan
      "#E5E9F0", -- white
    },

    -- ANSI colors (bright)
    brights = {
      "#4C566A", -- bright black / gray
      "#BF616A", -- bright red
      "#A3BE8C", -- bright green
      "#EBCB8B", -- bright yellow
      "#7AA2F7", -- bright blue
      "#B48EAD", -- bright magenta
      "#8FBCBB", -- bright cyan
      "#ECEFF4", -- bright white
    },

    tab_bar = {
      background = "#0F1724",
      active_tab = {
        bg_color = "#172033",
        fg_color = "#C8DCEF",
        intensity = "Bold",
      },
      inactive_tab = {
        bg_color = "#0F1724",
        fg_color = "#8892B0",
      },
      new_tab = {
        bg_color = "#0F1724",
        fg_color = "#7AA2F7",
      },
      inactive_tab_hover = {
        bg_color = "#16202C",
        fg_color = "#9AA7C8",
      },
    },
  },

  -- Make bold text slightly brighter which helps readability
  bold_brightens_ansi_colors = true,

  -- Appearance configuration
  font = wezterm.font("JetBrains Mono"),
  font_size = 13,
  animation_fps = 120,
  enable_scroll_bar = false,
  cursor_blink_rate = 800,
  cursor_thickness = 1.2,
  default_cursor_style = "BlinkingBlock",
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  adjust_window_size_when_changing_font_size = false,
  window_padding = {
    left = 5,
    right = 5,
    top = 5,
    bottom = 5,
  },
  window_background_opacity = 0.9,
  window_decorations = "RESIZE",
  macos_window_background_blur = 0,

  -- Key bindings configuration
  keys = {
    -- Turn off the default CMD-m Hide action
    { key = "m",          mods = "CMD",       action = wezterm.action.DisableDefaultAssignment },
    -- Navigate tabs in MacOS style
    { key = "LeftArrow",  mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
    -- Split panes key bindings
    { key = "\"",         mods = "CMD|SHIFT", action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = ":",          mods = "CMD|SHIFT", action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = "LeftArrow",  mods = "CMD|CTRL",  action = wezterm.action.ActivatePaneDirection "Left" },
    { key = "RightArrow", mods = "CMD|CTRL",  action = wezterm.action.ActivatePaneDirection "Right" },
    { key = "UpArrow",    mods = "CMD|CTRL",  action = wezterm.action.ActivatePaneDirection "Up" },
    { key = "DownArrow",  mods = "CMD|CTRL",  action = wezterm.action.ActivatePaneDirection "Down" },
    -- Screen options
    { key = "a",          mods = "CMD|SHIFT", action = wezterm.action.ToggleAlwaysOnTop },
    { key = "f",          mods = "CMD|SHIFT", action = wezterm.action.ToggleFullScreen },
  },

  -- Hyperlinks
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

-- Custom tab title formatter
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local process_name = tab.active_pane.foreground_process_name
  local title = tab.active_pane.title or ""

  -- Extract only the process name (remove full path)
  if process_name then
    process_name = string.match(process_name, "([^/]+)$")
  else
    process_name = ""
  end

  -- Replace process names with emojis
  local icon = ""
  if process_name == "bash" then
    icon = " ◉ "
  elseif process_name == "ssh" then
    icon = " 📡 "
  elseif process_name == "htop" then
    icon = " 👀 "
  else
    icon = " 💻 "
  end

  -- Get short name of the current working directory
  local cwd_uri = tab.active_pane.current_working_dir
  local cwd = ""
  if cwd_uri then
    cwd = string.gsub(cwd_uri.file_path, "^/Users/[^/]+", "~")
    cwd = string.match(cwd, ".*/([^/]+)$") or cwd
  end

  local is_active = tab.is_active
  local bg = is_active and "#172033" or "#0F1724"
  local fg = is_active and "#C8DCEF" or "#7AA2F7"

  -- Compose the final tab title
  return wezterm.format({
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = string.format(" %s %s ", icon, cwd) },
  })
end)


-- Return the final configuration to wezterm
return config
