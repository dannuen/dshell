#!/usr/bin/env bash
# Pull the latest dshell and run new migrations.
set -euo pipefail

REPO="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"
STATE="$HOME/.local/state/dshell"
MARK="$STATE/migration"
mkdir -p "$STATE"

info() { printf '\e[1;34m::\e[0m %s\n' "$*"; }

if [[ -d "$REPO/.git" ]]; then
    info "Pulling updates"
    git -C "$REPO" pull --ff-only
fi

last=0
[[ -f $MARK ]] && last=$(<"$MARK")

for m in "$REPO"/migrations/[0-9][0-9][0-9]_*.sh; do
    [[ -f $m ]] || continue
    n=$(basename "$m" | cut -d_ -f1)
    if (( 10#$n > 10#$last )); then
        info "Running migration $(basename "$m")"
        bash "$m"
        echo "$n" > "$MARK"
    fi
done

qs -c dshell ipc call shell reload >/dev/null 2>&1 || true
info "Done"
