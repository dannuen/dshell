-- Keybinds. The shell is reached through its IPC:
--   qs -c dshell ipc call <target> <function>
-- Super+/ shows this list inside the shell.

local function shell(target, fn)
    return hl.dsp.exec_cmd("qs -c dshell ipc call " .. target .. " " .. fn)
end

local function bind(keys, description, dispatcher, options)
    local opts = options or {}
    opts.description = description
    if type(dispatcher) == "string" then
        dispatcher = hl.dsp.exec_cmd(dispatcher)
    end
    hl.bind(keys, dispatcher, opts)
end

-- Apps ----------------------------------------------------------------
bind("SUPER + Return", "Terminal", "kitty")
bind("SUPER + E", "File manager", "nautilus")
bind("SUPER + B", "Browser", "brave")
bind("SUPER + O", "Obsidian", "obsidian")

-- Shell panels ----------------------------------------------------------
bind("SUPER + SPACE", "App launcher", shell("launcher", "toggle"))
bind("SUPER + V", "Clipboard history", shell("clipboard", "toggle"))
bind("SUPER + Tab", "Overview", shell("overview", "toggle"))
bind("SUPER + A", "Quick settings", shell("sidebar", "toggle"))
bind("SUPER + D", "Dashboard", shell("dashboard", "toggle"))
bind("SUPER + N", "Notification history", shell("notifs", "toggleHistory"))
bind("SUPER + SHIFT + N", "Dismiss notifications", shell("notifs", "dismissAll"))
bind("SUPER + W", "Wallpaper picker", shell("wallpaper", "toggle"))
bind("SUPER + SHIFT + W", "Random wallpaper", shell("wallpaper", "random"))
bind("SUPER + SHIFT + D", "Dark or light theme", shell("theme", "toggle"))
bind("SUPER + L", "Lock", shell("lock", "lock"))
bind("SUPER + Escape", "Session menu", shell("session", "toggle"))
bind("CTRL + ALT + Delete", "Session menu", shell("session", "toggle"))
bind("XF86PowerOff", "Session menu", shell("session", "toggle"), { locked = true })
bind("SUPER + comma", "Settings", shell("settings", "toggle"))
bind("SUPER + slash", "Keybind cheat sheet", shell("cheatsheet", "toggle"))
bind("SUPER + SHIFT + R", "Reload shell", shell("shell", "reload"))
bind("SUPER + CTRL + R", "Reload Hyprland config", "hyprctl reload")
bind("switch:on:Lid Switch", "Lock on lid close", shell("lock", "lock"), { locked = true })

-- Typing ----------------------------------------------------------------
bind("CTRL + SPACE", "Switch EN / VI typing", shell("input", "toggle"))

-- Windows ---------------------------------------------------------------
bind("SUPER + Q", "Close window", hl.dsp.window.close())
bind("SUPER + F", "Fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind("SUPER + T", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + SHIFT + T", "Float and center at 1000x660", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ x = 1000, y = 660, exact = true }))
    hl.dispatch(hl.dsp.window.center())
end)

bind("SUPER + Left", "Focus left", hl.dsp.focus({ direction = "l" }))
bind("SUPER + Right", "Focus right", hl.dsp.focus({ direction = "r" }))
bind("SUPER + Up", "Focus up", hl.dsp.focus({ direction = "u" }))
bind("SUPER + Down", "Focus down", hl.dsp.focus({ direction = "d" }))

bind("SUPER + SHIFT + Left", "Move window left", hl.dsp.window.move({ direction = "l" }))
bind("SUPER + SHIFT + Right", "Move window right", hl.dsp.window.move({ direction = "r" }))
bind("SUPER + SHIFT + Up", "Move window up", hl.dsp.window.move({ direction = "u" }))
bind("SUPER + SHIFT + Down", "Move window down", hl.dsp.window.move({ direction = "d" }))

bind("SUPER + CTRL + Left", "Shrink width", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
bind("SUPER + CTRL + Right", "Grow width", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
bind("SUPER + CTRL + Up", "Shrink height", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
bind("SUPER + CTRL + Down", "Grow height", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

bind("SUPER + mouse:272", "Drag window", hl.dsp.window.drag(), { mouse = true })
bind("SUPER + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

-- Workspaces ------------------------------------------------------------
-- keycodes 10..19 are the number row 1..9,0
for i = 1, 10 do
    local key = "code:" .. tostring(i + 9)
    local label = tostring(i)
    bind("SUPER + " .. key, "Workspace " .. label, hl.dsp.focus({ workspace = i }))
    bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. label, hl.dsp.window.move({ workspace = i, follow = false }))
end

bind("SUPER + mouse_down", "Next workspace", hl.dsp.focus({ workspace = "m+1" }))
bind("SUPER + mouse_up", "Previous workspace", hl.dsp.focus({ workspace = "m-1" }))

-- Special workspaces
bind("SUPER + M", "Music", hl.dsp.workspace.toggle_special("music"))
bind("SUPER + U", "Todo", hl.dsp.workspace.toggle_special("todo"))
bind("SUPER + S", "Scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
bind("SUPER + SHIFT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Screenshots -----------------------------------------------------------
bind("Print", "Screenshot area", "grimblast --notify copysave area")
bind("SHIFT + Print", "Screenshot screen", "grimblast --notify copysave output")
bind("SUPER + Print", "Screenshot window", "grimblast --notify copysave active")
bind("CTRL + Print", "Screenshot and edit", "grimblast --freeze save area - | swappy -f -")

-- Volume, brightness, media ---------------------------------------------
bind("XF86AudioRaiseVolume", "Volume up", shell("volume", "increase"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", "Volume down", shell("volume", "decrease"), { locked = true, repeating = true })
bind("XF86AudioMute", "Mute", shell("volume", "mute"), { locked = true })
bind("XF86AudioMicMute", "Mute microphone", shell("volume", "micMute"), { locked = true })
-- horizontal scroll (tilt or thumb wheel) is a volume knob, apps no longer get it
bind("mouse_right", "Volume up", shell("volume", "increase"), { locked = true })
bind("mouse_left", "Volume down", shell("volume", "decrease"), { locked = true })
bind("XF86MonBrightnessUp", "Brightness up", shell("brightness", "increase"), { locked = true, repeating = true })
bind("XF86MonBrightnessDown", "Brightness down", shell("brightness", "decrease"), { locked = true, repeating = true })
bind("XF86AudioPlay", "Play or pause", shell("media", "playPause"), { locked = true })
bind("XF86AudioPause", "Play or pause", shell("media", "playPause"), { locked = true })
bind("XF86AudioNext", "Next track", shell("media", "next"), { locked = true })
bind("XF86AudioPrev", "Previous track", shell("media", "previous"), { locked = true })
