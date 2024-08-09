-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

-- shell
config.default_prog = { "/usr/bin/zsh" }

-- window
config.window_decorations = "RESIZE"

-- tab bar
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- color scheme
config.color_scheme = "tokyonight_night"
config.colors = {
    cursor_bg = "#ff0000",
    cursor_fg = "black",
    tab_bar = {
        -- match tokyonight_night background to reduce clutter
        inactive_tab = {
            bg_color = "#1a1b26",
            fg_color = "#888888",
        },
    },
}

-- font
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14.0

-- disable ligatures in most fonts
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- keys
config.keys = {
    -- tabs
    { key = "RightArrow", mods = "ALT", action = act.ActivateTabRelative(1) },
    { key = "LeftArrow", mods = "ALT", action = act.ActivateTabRelative(-1) },
    { key = "l", mods = "ALT", action = act.ActivateTabRelative(1) },
    { key = "h", mods = "ALT", action = act.ActivateTabRelative(-1) },
    { key = "Enter", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "q", mods = "ALT", action = act.CloseCurrentTab({ confirm = true }) },
    -- panes
    { key = "Space", mods = "ALT|CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
}

return config
