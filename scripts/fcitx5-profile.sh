#!/usr/bin/env bash
# Write the fcitx5 input method list: US keyboard plus whichever Vietnamese
# engine is installed (lotus, else bamboo). fcitx5 rewrites its profile on
# its own, so the repo ships no profile and this script makes one.
#   fcitx5-profile.sh           only if there is no profile yet
#   fcitx5-profile.sh --force   replace the current list
set -euo pipefail

PROFILE="$HOME/.config/fcitx5/profile"
IM_DIR=/usr/share/fcitx5/inputmethod

log() { echo "[fcitx5-profile] $*"; }

if [[ ${1:-} != --force && -f $PROFILE ]]; then
    exit 0
fi

vi=""
for im in lotus bamboo; do
    if [[ -f $IM_DIR/$im.conf ]]; then
        vi=$im
        break
    fi
done
[[ -n $vi ]] || log "no Vietnamese input method installed (fcitx5-lotus or fcitx5-bamboo), using the US keyboard only"

# A running fcitx5 saves its own list over the file when it exits, so tell
# it the new list instead of writing the file behind its back.
if pgrep -x fcitx5 >/dev/null 2>&1 && command -v busctl >/dev/null 2>&1; then
    items=(1 keyboard-us "")
    [[ -n $vi ]] && items=(2 "$vi" "" keyboard-us "")
    if busctl --user call org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1 \
        SetInputMethodGroupInfo 'ssa(ss)' Default us "${items[@]}" >/dev/null 2>&1 &&
        busctl --user call org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1 Save >/dev/null 2>&1; then
        log "input methods: ${vi:+$vi, }keyboard-us"
        exit 0
    fi
fi

mkdir -p "$(dirname "$PROFILE")"
{
    printf '[Groups/0]\n# Group Name\nName=Default\n# Layout\nDefault Layout=us\n# Default Input Method\nDefaultIM=keyboard-us\n\n'
    n=0
    for im in $vi keyboard-us; do
        printf '[Groups/0/Items/%d]\n# Name\nName=%s\n# Layout\n# Layout=\n\n' "$n" "$im"
        n=$((n + 1))
    done
    printf '[GroupOrder]\n0=Default\n\n'
} > "$PROFILE"
log "input methods: ${vi:+$vi, }keyboard-us"
