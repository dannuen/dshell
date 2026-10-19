-- Programs started with Hyprland.

local home = os.getenv("HOME") or ""

hl.on("hyprland.start", function()
    -- systemd and D-Bus need the session vars first
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- the shell
    hl.exec_cmd("qs -c dshell")

    -- session helpers
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent || hyprpolkitagent")
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprsunset")

    -- laptop screen off when the external one is plugged in
    hl.exec_cmd(home .. "/.config/hypr/scripts/display-toggle.sh")

    -- wallpaper and colors from last time
    hl.exec_cmd(home .. "/.config/hypr/scripts/wallpaper.sh restore")
end)

-- Re-check the laptop screen when monitors come and go
hl.on("monitor.added", function()
    hl.exec_cmd("sleep 1; " .. home .. "/.config/hypr/scripts/display-toggle.sh")
end)

hl.on("monitor.removed", function()
    hl.exec_cmd("sleep 1; " .. home .. "/.config/hypr/scripts/display-toggle.sh")
end)
