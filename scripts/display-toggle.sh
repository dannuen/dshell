#!/usr/bin/env bash
# Turn the laptop screen off when an external display is connected,
# and back on when none is. Uses the Hyprland Lua API through hyprctl eval.
# Needs: hyprctl, jq
set -euo pipefail

INTERNAL_PATTERN='^eDP-'
LOG_TAG="dshell-display-toggle"

log() { echo "[$LOG_TAG] $*"; }

command -v hyprctl >/dev/null 2>&1 || { log "hyprctl not found"; exit 1; }
command -v jq >/dev/null 2>&1 || { log "jq not found"; exit 1; }

ALL_JSON="$(hyprctl monitors all -j)"
ACTIVE_JSON="$(hyprctl monitors -j)"

INTERNAL_NAME="$(echo "$ALL_JSON" | jq -r --arg pat "$INTERNAL_PATTERN" '[.[] | select(.name | test($pat))][0].name // empty')"

if [[ -z $INTERNAL_NAME ]]; then
    log "no internal display matching '$INTERNAL_PATTERN', nothing to do"
    exit 0
fi

EXTERNAL_COUNT="$(echo "$ALL_JSON" | jq --arg name "$INTERNAL_NAME" '[.[] | select(.name != $name and (.disabled | not))] | length')"
INTERNAL_ACTIVE="$(echo "$ACTIVE_JSON" | jq --arg name "$INTERNAL_NAME" '[.[] | select(.name == $name)] | length > 0')"

log "internal: $INTERNAL_NAME, external count: $EXTERNAL_COUNT, internal enabled: $INTERNAL_ACTIVE"

disable_internal() {
    hyprctl eval "hl.monitor({ output = \"$INTERNAL_NAME\", disabled = true })"
}

enable_internal() {
    hyprctl eval "hl.monitor({ output = \"$INTERNAL_NAME\", mode = \"preferred\", position = \"auto\", scale = 1, disabled = false })"
}

if (( EXTERNAL_COUNT >= 1 )); then
    if [[ $INTERNAL_ACTIVE == true ]]; then
        log "external present, disabling internal"
        disable_internal
    fi
else
    if [[ $INTERNAL_ACTIVE != true ]]; then
        log "no external, enabling internal"
        enable_internal
    fi
fi
