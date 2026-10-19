-- Monitors and workspaces.
-- List outputs with: hyprctl monitors all

-- Fallback: any monitor not listed below
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- External 4K (ASUS PA279CV)
hl.monitor({
    output = "desc:ASUSTek COMPUTER INC ASUS PA279CV R9LMTF060704",
    mode = "3840x2160@60.00",
    position = "0x0",
    scale = 1.25,
})

-- Laptop panel
hl.monitor({
    output = "desc:California Institute of Technology 0x140C",
    mode = "2880x1800@90.00",
    position = "-2165.5x0", -- 2880/scale
    scale = 1.33,
})

-- Workspaces: 1 and 5 on the laptop, 2 to 4 on the external, 6 to 10 dynamic
hl.workspace_rule({ workspace = "1", persistent = true, monitor = "eDP-1" })
hl.workspace_rule({ workspace = "2", persistent = true, monitor = "DP-1" })
hl.workspace_rule({ workspace = "3", persistent = true, monitor = "DP-1" })
hl.workspace_rule({ workspace = "4", persistent = true, monitor = "DP-1" })
hl.workspace_rule({ workspace = "5", persistent = true, monitor = "eDP-1" })

for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), persistent = false })
end
