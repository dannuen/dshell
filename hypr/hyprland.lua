-- dshell Hyprland config (Hyprland 0.55 or newer, Lua).
-- Each file under cfg/ is loaded in its own scope, so an error in one file
-- does not stop the others. Put personal overrides in ~/.config/hypr/user.lua
-- (not shipped, loaded last if it exists).

require("cfg.env")
require("cfg.display")
require("cfg.input")
require("cfg.layout")
require("cfg.animation")
require("cfg.rules")
require("cfg.keybinds")
require("cfg.autostart")
require("cfg.misc")

pcall(require, "user")
