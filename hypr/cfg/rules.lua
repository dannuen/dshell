-- Window and layer rules. One short block per app.

-- Do not let apps take over the screen when they ask to maximize
hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- XWayland drag fix
hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Zen browser on workspace 2, YouTube opaque
hl.window_rule({ match = { class = "zen" }, workspace = "2" })
hl.window_rule({
    match = { class = "^(zen)$", title = ".*- YouTube — Zen Browser$" },
    opaque = true,
})

-- Obsidian on 3
hl.window_rule({
    match = { class = "md.obsidian.Obsidian" },
    workspace = "3",
    opaque = true,
    no_dim = true,
    border_size = 1,
})

-- Calibre
hl.window_rule({
    match = { class = "^(calibre-gui)$" },
    float = true,
    size = { 1920, 1080 },
    center = true,
    keep_aspect_ratio = true,
    workspace = "4",
})
hl.window_rule({
    match = { class = "^(calibre-ebook-viewer)$" },
    float = true,
    size = { 801, 1123 },
    center = true,
    workspace = "3",
})
hl.window_rule({
    match = { title = "^(Table of Contents)$" },
    float = true,
    size = { 335, 1142 },
})

-- Zalo (Brave web app) on 5
hl.window_rule({
    match = { class = "^(brave-chat\\.zalo\\.me__-Default)$" },
    float = false,
    workspace = "5",
})

-- Apple Music and TickTick live on special workspaces (Super+M, Super+U)
hl.window_rule({ match = { class = "brave-music.apple.com__-Default" }, workspace = "special:music" })
hl.window_rule({ match = { class = "ticktick" }, workspace = "special:todo" })

-- Floating tools
hl.window_rule({
    match = { class = "^(org.gnome.Nautilus)$" },
    float = true,
    center = true,
    size = { 1300, 800 },
})
hl.window_rule({
    match = { class = "^(org\\.pulseaudio\\.pavucontrol)$" },
    float = true,
    center = true,
    size = { 802, 534 },
})
hl.window_rule({
    match = { class = "^(org.fcitx.fcitx5-config-qt)$" },
    float = true,
    center = true,
    size = { 1000, 660 },
})
hl.window_rule({
    match = { class = "^(org.fcitx.Fcitx5.Addon.Lotus.Settings)$" },
    float = true,
    center = true,
    size = { 1000, 660 },
})
hl.window_rule({
    match = { title = "^(Bitwarden)$" },
    float = true,
    center = true,
    no_screen_share = true,
})

-- Steam
hl.window_rule({ match = { class = "steam" }, float = true, idle_inhibit = "fullscreen" })
hl.window_rule({ match = { class = "steam", title = "Steam" }, center = true, size = { 1100, 700 } })
hl.window_rule({ match = { class = "steam.*" }, opaque = true })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, size = { 460, 800 } })

-- dshell layers get blur. Patterns must match the whole namespace.
hl.layer_rule({ match = { namespace = "^dshell-.*$" }, blur = true, ignore_alpha = 0.3 })
