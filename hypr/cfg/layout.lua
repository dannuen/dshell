-- Gaps, borders, blur, opacity.
-- Border colors come from ~/.config/hypr/colors.lua, written by matugen.

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 8,
        float_gaps = 2,
        gaps_workspaces = 25,
        border_size = 1,
        resize_on_border = true,
        extend_border_grab_area = 15,
        hover_icon_on_border = true,
        allow_tearing = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2.0,
        active_opacity = 0.95,
        inactive_opacity = 0.90,
        fullscreen_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.1,
        dim_special = 0.7,
        dim_around = 0.4,

        blur = {
            enabled = true,
            size = 10,
            passes = 3,
            ignore_opacity = true,
            new_optimizations = true,
            vibrancy = 0.17,
            vibrancy_darkness = 0.1,
            special = false,
            popups = true,
            popups_ignorealpha = 0.2,
        },

        shadow = {
            enabled = false,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    binds = {
        workspace_back_and_forth = true,
    },
})

-- Wallpaper colors (optional, created by scripts/wallpaper.sh)
pcall(require, "colors")
