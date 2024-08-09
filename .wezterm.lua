-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local config = {}

-- shell
config.default_prog = { "/usr/bin/zsh" }

-- maximize on startup
wezterm.on("gui-startup", function(cmd)
    local _, _, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

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

-- leader key configuration
config.leader = { key = "Space", mods = "ALT", timeout_milliseconds = 2000 }

-- keys
config.keys = {
    -- tabs
    { key = "RightArrow", mods = "ALT", action = act.ActivateTabRelative(1) },
    { key = "LeftArrow", mods = "ALT", action = act.ActivateTabRelative(-1) },
    { key = "l", mods = "ALT", action = act.ActivateTabRelative(1) },
    { key = "h", mods = "ALT", action = act.ActivateTabRelative(-1) },
    { key = "Enter", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "q", mods = "ALT", action = act.CloseCurrentTab({ confirm = true }) },

    -- split panes
    { key = "|", mods = "SHIFT|LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- move panes
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },

    -- resize panes
    { key = "h", mods = "ALT|LEADER", action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = "l", mods = "ALT|LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "k", mods = "ALT|LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
    { key = "j", mods = "ALT|LEADER", action = act.AdjustPaneSize({ "Down", 5 }) },
}

return config
