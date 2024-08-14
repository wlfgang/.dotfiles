-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local config = {}
local sshs = require("ssh")

-- shell
config.default_prog = { "/usr/bin/zsh" }

-- import ssh domains
sshs.apply_to_config(config)

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

-- show active workspace on tab bar
wezterm.on("update-right-status", function(window, pane)
    window:set_right_status(window:active_workspace())
end)

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
    { key = "t", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "RightArrow", mods = "ALT", action = act.ActivateTabRelative(1) },
    { key = "LeftArrow", mods = "ALT", action = act.ActivateTabRelative(-1) },
    { key = "l", mods = "ALT", action = act.ActivateTabRelative(1) },
    { key = "h", mods = "ALT", action = act.ActivateTabRelative(-1) },
    { key = "q", mods = "ALT", action = act.CloseCurrentTab({ confirm = true }) },

    -- split panes
    { key = "Enter", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "Space", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- move panes
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },

    -- resize panes
    { key = "h", mods = "CTRL", action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = "l", mods = "CTRL", action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "k", mods = "CTRL", action = act.AdjustPaneSize({ "Up", 5 }) },
    { key = "j", mods = "CTRL", action = act.AdjustPaneSize({ "Down", 5 }) },

    -- workspaces
    { key = "w", mods = "ALT", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
    { key = "n", mods = "ALT", action = act.SwitchWorkspaceRelative(1) },
    { key = "p", mods = "ALT", action = act.SwitchWorkspaceRelative(-1) },

    -- rename current workspace
    {
        key = "$",
        mods = "LEADER|SHIFT",
        action = act.PromptInputLine({
            description = "Enter new name for workspace",
            action = wezterm.action_callback(function(window, _, line)
                if line then
                    mux.rename_workspace(window:mux_window():get_workspace(), line)
                end
            end),
        }),
    },
}

return config
