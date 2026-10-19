# dshell

A hand written Quickshell desktop for Hyprland on CachyOS. One floating bar,
panels that slide out from it, Material You colors from the wallpaper,
Vietnamese typing with fcitx5, and the Hyprland setup from the old danarchy
config without Omarchy.

## Needs

- CachyOS or Arch
- Hyprland 0.55 or newer (Lua config). The installer updates the system first.
- An internet connection for the AUR packages

## Install

```sh
git clone <this repo> ~/dshell
cd ~/dshell
bash install.sh
```

Then log out, pick Hyprland in SDDM, and log in.

The installer backs up `~/.config/hypr`, `~/.config/quickshell/dshell`,
`~/.config/kitty`, `~/.config/fish/config.fish`, `~/.config/starship.toml`,
`~/.config/fcitx5` and `~/.config/fastfetch` into
`~/.config/dshell-backup-<date>/` before it links the new files.

Flags: `--no-update` (skip pacman -Syu), `--no-aur`, `--copy` (copy instead of
symlink), `--dry-run`.

## Layout

```
install.sh  update.sh  migrations/   installer, updater, update steps
packages.txt  packages-aur.txt       package lists
quickshell/dshell/                   the shell (qs -c dshell)
  shell.qml  config/  services/  modules/  components/  utils/  ipc/
hypr/                                Hyprland Lua config
  hyprland.lua  cfg/  hypridle.conf  hyprsunset.conf  xdph.conf
templates/                           matugen color templates
scripts/                             wallpaper, display toggle, screenshots, web apps, yt-dlp
dotfiles/                            kitty, fish, starship, fcitx5, fastfetch
```

## Keys

| Key | Action |
|---|---|
| Super+Return | Terminal (kitty) |
| Super+Space | App launcher. Prefixes: `=` calculator, `>` run command, `:` emoji, `@` windows, `;` clipboard, `/` wallpaper |
| Super+E | Files (Nautilus) |
| Super+B / Super+O | Brave / Obsidian |
| Super+Q | Close window |
| Super+F / Super+T | Fullscreen / toggle floating |
| Super+Shift+T | Float and center at 1000x660 |
| Super+M / Super+U | Music / todo special workspace |
| Super+S / Super+Shift+S | Show scratchpad / move window to scratchpad |
| Ctrl+Space | Switch EN / VI typing |
| Super+1..9, 0 | Go to workspace 1 to 10 |
| Super+Shift+1..9, 0 | Move window to workspace |
| Super+Arrows | Focus window |
| Super+Shift+Arrows | Move window |
| Super+Ctrl+Arrows | Resize window |
| Super+Tab | Overview |
| Super+V | Clipboard history |
| Super+W / Super+Shift+W | Wallpaper picker / random wallpaper |
| Super+Shift+D | Dark or light theme |
| Super+N / Super+Shift+N | Notification history / dismiss popups |
| Super+A | Quick settings sidebar |
| Super+D | Dashboard |
| Super+L | Lock |
| Super+Escape | Session menu |
| Super+, | Settings |
| Super+/ | Keybind cheat sheet |
| Super+Shift+R | Reload the shell |
| Super+Ctrl+R | Reload Hyprland config |
| Print / Shift+Print / Super+Print | Screenshot area / screen / window |
| Ctrl+Print | Screenshot area and edit in swappy |
| Volume, brightness, media keys | Work with the OSD |

## Settings

User settings live in `~/.config/dshell/settings.json`. Only the keys you
change need to be there, defaults are in `quickshell/dshell/config/Config.qml`.
The file is watched, so edits apply live. Super+, opens a settings panel that
writes the same file.

## Theme

Pick a wallpaper with Super+W, or run:

```sh
~/.config/hypr/scripts/wallpaper.sh set ~/Pictures/Wallpapers/some.jpg
```

The script sets the wallpaper (swww), runs matugen with the templates in
`~/.config/dshell/templates/`, and writes colors for the shell, kitty,
Hyprland borders and GTK. Dark or light mode is `theme.mode` in settings.json,
or Super+Shift+D. Put wallpapers in `~/Pictures/Wallpapers` (change
`wallpaper.dir` in settings to use another folder).

## Your own changes

- `~/.config/hypr/user.lua` is loaded last and can change any Hyprland setting
  or add binds. It is not part of the repo, so updates never touch it.
- `~/.config/fish/user.fish` is sourced by the fish config if it exists.
- `~/.config/dshell/settings.json` for the shell.

## Update

```sh
cd ~/dshell && bash update.sh
```

This pulls the repo, runs new scripts from `migrations/` and reloads the shell.

## Problems

- Shell does not start or looks wrong: run `qs -c dshell` in a terminal, it
  prints QML errors.
- Hyprland config error: `hyprctl reload` prints it. Check `hyprctl version`
  is 0.55 or newer.
- Icons show as text: run `bash scripts/fonts.sh`. It installs the
  Material Symbols Rounded font (download, no AUR needed) and the Nerd
  Font, then refreshes the font cache. Restart the shell with Super+Shift+R.
- Colors did not change: `matugen` must be installed, and
  `~/.config/dshell/matugen.toml` must exist (install.sh copies it).
- Lint everything: `bash scripts/check.sh`.
