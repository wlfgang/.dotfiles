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
    { key = "y", mods = "ALT", action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = "o", mods = "ALT", action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "i", mods = "ALT", action = act.AdjustPaneSize({ "Up", 5 }) },
    { key = "u", mods = "ALT", action = act.AdjustPaneSize({ "Down", 5 }) },

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

local function segments_for_right_status(window)
    return {
        window:active_workspace(),
        wezterm.strftime("%a %b %-d %H:%M"),
        wezterm.hostname(),
    }
end

wezterm.on("update-status", function(window, _)
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
    local segments = segments_for_right_status(window)

    local color_scheme = window:effective_config().resolved_palette
    -- Note the use of wezterm.color.parse here, this returns
    -- a Color object, which comes with functionality for lightening
    -- or darkening the colour (amongst other things).
    local bg = wezterm.color.parse(color_scheme.background)
    local fg = color_scheme.foreground

    -- Each powerline segment is going to be coloured progressively
    -- darker/lighter depending on whether we're on a dark/light colour
    -- scheme. Let's establish the "from" and "to" bounds of our gradient.
    local gradient_to, gradient_from = bg
    gradient_from = gradient_to:lighten(0.2)

    -- Yes, WezTerm supports creating gradients, because why not?! Although
    -- they'd usually be used for setting high fidelity gradients on your terminal's
    -- background, we'll use them here to give us a sample of the powerline segment
    -- colours we need.
    local gradient = wezterm.color.gradient(
        {
            orientation = "Horizontal",
            colors = { gradient_from, gradient_to },
        },
        #segments -- only gives us as many colours as we have segments.
    )

    -- We'll build up the elements to send to wezterm.format in this table.
    local elements = {}

    for i, seg in ipairs(segments) do
        local is_first = i == 1

        if is_first then
            table.insert(elements, { Background = { Color = "none" } })
        end
        table.insert(elements, { Foreground = { Color = gradient[i] } })
        table.insert(elements, { Text = SOLID_LEFT_ARROW })

        table.insert(elements, { Foreground = { Color = fg } })
        table.insert(elements, { Background = { Color = gradient[i] } })
        table.insert(elements, { Text = " " .. seg .. " " })
    end

    window:set_right_status(wezterm.format(elements))
end)

return config
