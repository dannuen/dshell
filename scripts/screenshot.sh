#!/usr/bin/env bash
# Screenshots with grimblast. Saved to ~/Pictures/Screenshots and copied.
#   screenshot.sh area | output | active | edit
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

command -v grimblast >/dev/null 2>&1 || { notify-send "Screenshot" "grimblast is not installed" 2>/dev/null || true; exit 1; }

case "${1:-area}" in
    area)   grimblast --notify --freeze copysave area "$FILE" ;;
    output) grimblast --notify copysave output "$FILE" ;;
    active) grimblast --notify copysave active "$FILE" ;;
    edit)
        if command -v swappy >/dev/null 2>&1; then
            grimblast --freeze save area - | swappy -f - -o "$FILE"
        else
            grimblast --notify --freeze copysave area "$FILE"
        fi
        ;;
    *) echo "usage: screenshot.sh area|output|active|edit" >&2; exit 1 ;;
esac
