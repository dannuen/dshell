#!/usr/bin/env bash
# Make sure the fonts dshell needs are installed and visible to fontconfig.
#
#   fonts.sh          install what is missing, then refresh the font cache
#   fonts.sh check    only report, exit 1 if something is missing
#
# The icon font (Material Symbols Rounded) comes from the AUR package
# ttf-material-symbols-variable-git. When that is not installed, this
# script downloads the same variable font file from Google's repo into
# ~/.local/share/fonts so the shell works without the AUR.
set -euo pipefail

FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
ICON_FAMILY="Material Symbols Rounded"
ICON_FILE='MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf'
ICON_URL='https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf'
TEXT_FAMILY="CaskaydiaCove Nerd Font"

have_family() { fc-list : family | grep -qiF "$1"; }

status=0
if have_family "$ICON_FAMILY"; then
    echo " ok  $ICON_FAMILY"
else
    echo " !!  $ICON_FAMILY is missing (icons show as text)"
    status=1
fi
if have_family "$TEXT_FAMILY"; then
    echo " ok  $TEXT_FAMILY"
else
    echo " !!  $TEXT_FAMILY is missing (pacman -S ttf-cascadia-code-nerd)"
    status=1
fi

[[ ${1:-} == check ]] && exit "$status"
(( status == 0 )) && exit 0

if ! have_family "$ICON_FAMILY"; then
    echo " ->  downloading $ICON_FAMILY to $FONT_DIR"
    mkdir -p "$FONT_DIR"
    curl -fsSL --retry 3 -o "$FONT_DIR/$ICON_FILE" "$ICON_URL"
fi
if ! have_family "$TEXT_FAMILY" && command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm ttf-cascadia-code-nerd || true
fi

fc-cache -f >/dev/null
echo " ->  font cache refreshed"
have_family "$ICON_FAMILY" || { echo " !!  $ICON_FAMILY still not found. Check: fc-list | grep -i material"; exit 1; }
echo " ok  fonts ready. Restart the shell: Super+Shift+R or 'qs -c dshell'"
