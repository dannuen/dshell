#!/usr/bin/env bash
# dshell wallpaper and theme script.
#   wallpaper.sh set <image>   set wallpaper, rebuild colors with matugen
#   wallpaper.sh restore       set the last wallpaper again (used at login)
#   wallpaper.sh colors <image>  only rebuild colors
# Env: DSHELL_NO_WALLPAPER=1 skips the wallpaper step (no compositor yet).
# The last line printed is the wallpaper path, the shell reads it.
set -uo pipefail

STATE_DIR="$HOME/.local/state/dshell"
SETTINGS="$HOME/.config/dshell/settings.json"
MATUGEN_CFG="$HOME/.config/dshell/matugen.toml"
SAVED="$STATE_DIR/wallpaper"
WALL_DIR="$HOME/Pictures/Wallpapers"
FALLBACK_COLOR="#555dcb"

mkdir -p "$STATE_DIR"

setting() {
    # setting <jq path> <default>
    local v=""
    if [[ -f "$SETTINGS" ]] && command -v jq >/dev/null 2>&1; then
        v=$(jq -r "$1 // empty" "$SETTINGS" 2>/dev/null || true)
    fi
    printf '%s' "${v:-$2}"
}

run_matugen() {
    # run_matugen image <path> | run_matugen color <hex>
    command -v matugen >/dev/null 2>&1 || { echo "matugen not found, colors not updated" >&2; return 0; }
    local mode scheme prefer
    mode=$(setting '.theme.mode' dark)
    scheme=$(setting '.theme.scheme' scheme-tonal-spot)
    # matugen 4 asks which source color to use unless --prefer is given,
    # and fails when there is no terminal (like when the shell runs us)
    prefer=$(setting '.theme.prefer' saturation)
    local args=(-m "$mode" -t "$scheme" --prefer "$prefer")
    [[ -f "$MATUGEN_CFG" ]] && args+=(-c "$MATUGEN_CFG")
    if [[ $1 == image ]]; then
        matugen image "$2" "${args[@]}" >/dev/null 2>&1 || echo "matugen failed for $2" >&2
    else
        matugen color hex "$2" "${args[@]}" >/dev/null 2>&1 || echo "matugen failed for color $2" >&2
    fi
    sync_gtk "$mode"
}

sync_gtk() {
    # Match GTK's light/dark setting to the shell and make running GTK apps
    # pick up the new gtk.css (they only re-read it when the theme changes).
    command -v gsettings >/dev/null 2>&1 || return 0
    local iface=org.gnome.desktop.interface theme other
    if [[ $1 == light ]]; then
        gsettings set $iface color-scheme prefer-light
        theme=adw-gtk3 other=adw-gtk3-dark
    else
        gsettings set $iface color-scheme prefer-dark
        theme=adw-gtk3-dark other=adw-gtk3
    fi
    [[ -d /usr/share/themes/$theme || -d $HOME/.local/share/themes/$theme ]] || return 0
    gsettings set $iface gtk-theme "$other"
    sleep 0.2
    gsettings set $iface gtk-theme "$theme"
}

apply_wallpaper() {
    local img="$1"
    [[ ${DSHELL_NO_WALLPAPER:-0} == 1 ]] && return 0
    [[ -z ${WAYLAND_DISPLAY:-} ]] && return 0
    local transition
    transition=$(setting '.wallpaper.transition' fade)
    # awww is the current name of swww, keep swww for older installs
    if command -v awww >/dev/null 2>&1; then
        pgrep -x awww-daemon >/dev/null 2>&1 || { awww-daemon >/dev/null 2>&1 & sleep 0.5; }
        awww img "$img" --transition-type "$transition" --transition-duration 1 >/dev/null 2>&1 \
            || echo "awww failed to set $img" >&2
    elif command -v swww >/dev/null 2>&1; then
        pgrep -x swww-daemon >/dev/null 2>&1 || { swww-daemon >/dev/null 2>&1 & sleep 0.5; }
        swww img "$img" --transition-type "$transition" --transition-duration 1 >/dev/null 2>&1 \
            || echo "swww failed to set $img" >&2
    elif command -v hyprpaper >/dev/null 2>&1; then
        hyprctl hyprpaper reload ",$img" >/dev/null 2>&1 || echo "hyprpaper failed to set $img" >&2
    else
        echo "no wallpaper tool found, install awww" >&2
    fi
}

run_hook() {
    local hook
    hook=$(setting '.hooks.wallpaperChanged' "")
    [[ -n $hook ]] && (sh -c "$hook" >/dev/null 2>&1 &)
    return 0
}

do_set() {
    local img="$1"
    if [[ ! -f $img ]]; then
        echo "no such file: $img" >&2
        exit 1
    fi
    img=$(realpath "$img")
    printf '%s\n' "$img" > "$SAVED"
    apply_wallpaper "$img"
    run_matugen image "$img"
    run_hook
    printf '%s\n' "$img"
}

do_restore() {
    local img=""
    [[ -f $SAVED ]] && img=$(<"$SAVED")
    if [[ -z $img || ! -f $img ]]; then
        img=$(find "$WALL_DIR" -maxdepth 2 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort | head -n1 || true)
    fi
    if [[ -z $img ]]; then
        local here
        here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
        [[ -f "$here/../assets/default.jpg" ]] && img="$here/../assets/default.jpg"
    fi
    if [[ -n $img && -f $img ]]; then
        do_set "$img"
    else
        echo "no wallpaper found in $WALL_DIR, using a plain color scheme" >&2
        run_matugen color "$FALLBACK_COLOR"
        run_hook
        echo ""
    fi
}

case "${1:-}" in
    set)
        [[ -n ${2:-} ]] || { echo "usage: wallpaper.sh set <image>" >&2; exit 1; }
        do_set "$2"
        ;;
    restore)
        do_restore
        ;;
    colors)
        [[ -n ${2:-} ]] || { echo "usage: wallpaper.sh colors <image>" >&2; exit 1; }
        run_matugen image "$(realpath "$2")"
        run_hook
        ;;
    *)
        echo "usage: wallpaper.sh set <image> | restore | colors <image>" >&2
        exit 1
        ;;
esac
