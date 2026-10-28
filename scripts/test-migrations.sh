#!/usr/bin/env bash
# Test update.sh migration logic in a temp dir: each migration runs once, in
# order, and a failing one stops the run without moving the marker.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

FAKE="$TMP/repo"
LOG="$TMP/log"
MARK="$TMP/home/.local/state/dshell/migration"
mkdir -p "$FAKE/migrations" "$TMP/home"
cp "$ROOT/update.sh" "$FAKE/update.sh"
for n in 001_a 009_b 010_c; do
    printf '#!/usr/bin/env bash\necho %s >> "%s"\n' "${n%%_*}" "$LOG" > "$FAKE/migrations/$n.sh"
done

fail=0
check() {
    # check <name> <got> <want>
    if [[ $2 == "$3" ]]; then
        echo "   ok $1"
    else
        echo "   fail $1: got '$2', want '$3'"
        fail=1
    fi
}

HOME="$TMP/home" bash "$FAKE/update.sh" >/dev/null 2>&1
HOME="$TMP/home" bash "$FAKE/update.sh" >/dev/null 2>&1
check "each migration runs once" "$(cat "$LOG")" "$(printf '001\n009\n010')"
check "marker after run" "$(cat "$MARK")" "010"

printf '#!/usr/bin/env bash\nexit 1\n' > "$FAKE/migrations/011_d.sh"
HOME="$TMP/home" bash "$FAKE/update.sh" >/dev/null 2>&1
check "update.sh fails on a bad migration" "$?" "1"
check "marker stays after failure" "$(cat "$MARK")" "010"

exit $fail
