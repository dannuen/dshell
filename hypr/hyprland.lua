-- dshell Hyprland config (Hyprland 0.55 or newer, Lua).
-- Each file under cfg/ is loaded with pcall, so an error in one file
-- is printed and does not stop the others. Put personal overrides in
-- ~/.config/hypr/user.lua (not shipped, loaded last if it exists).

for _, name in ipairs({
    "cfg.env",
    "cfg.display",
    "cfg.input",
    "cfg.layout",
    "cfg.animation",
    "cfg.rules",
    "cfg.keybinds",
    "cfg.autostart",
    "cfg.misc",
}) do
    local ok, err = pcall(require, name)
    if not ok then
        print("dshell: " .. tostring(err))
    end
end

pcall(require, "user")
