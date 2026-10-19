-- Animations: springs for movement, short beziers for fades.

hl.curve("spring_stiff", { type = "spring", mass = 1, stiffness = 1100, dampening = 66 })
hl.curve("spring_medium", { type = "spring", mass = 1, stiffness = 950, dampening = 62 })
hl.curve("spring_soft", { type = "spring", mass = 1, stiffness = 850, dampening = 58 })
hl.curve("spring_bouncy", { type = "spring", mass = 1, stiffness = 1300, dampening = 46 })

hl.curve("ease_out_quad", { type = "bezier", points = { { 0.25, 0.46 }, { 0.45, 0.94 } } })
hl.curve("ease_out_cubic", { type = "bezier", points = { { 0.215, 0.61 }, { 0.355, 1.0 } } })

hl.animation({ leaf = "workspaces", enabled = true, speed = 5, spring = "spring_stiff", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, spring = "spring_medium", style = "slidevert" })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "ease_out_quad", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "ease_out_cubic", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, spring = "spring_soft" })

hl.animation({ leaf = "layers", enabled = true, speed = 4, spring = "spring_bouncy", style = "slide" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "ease_out_quad" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "ease_out_quad" })
