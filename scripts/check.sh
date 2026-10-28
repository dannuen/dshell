#!/usr/bin/env bash
# Lint everything: shellcheck for scripts, qmllint for QML.
# Exit 1 on shell errors or QML syntax errors. Unknown Quickshell imports are
# expected when qmllint cannot see the Quickshell modules and are not errors.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

echo ":: shellcheck"
if command -v shellcheck >/dev/null 2>&1; then
    mapfile -t sh_files < <(find "$ROOT" -type f -name '*.sh' -not -path '*/.git/*'; printf '%s\n' "$ROOT/install.sh" "$ROOT/update.sh")
    if ! shellcheck -S warning "${sh_files[@]}"; then
        fail=1
    else
        echo "   ok (${#sh_files[@]} files)"
    fi
else
    echo "   shellcheck not installed, skipped"
fi

echo ":: qmllint"
QMLLINT=""
for c in qmllint qmllint6 /usr/lib/qt6/bin/qmllint; do
    if command -v "$c" >/dev/null 2>&1; then QMLLINT="$c"; break; fi
done
if [[ -n $QMLLINT ]]; then
    mapfile -t qml_files < <(find "$ROOT/quickshell" -type f -name '*.qml')
    errors=0
    for f in "${qml_files[@]}"; do
        out=$("$QMLLINT" --json - "$f" 2>/dev/null || true)
        # only count real syntax errors, not unresolved Quickshell types
        n=$(printf '%s' "$out" | jq '[.files[].warnings[]? | select(.type == "critical" and (.message | test("Quickshell|qs\\.|import") | not))] | length' 2>/dev/null || echo 0)
        if [[ ${n:-0} -gt 0 ]]; then
            echo "   $f"
            printf '%s' "$out" | jq -r '.files[].warnings[]? | select(.type == "critical") | "     line \(.line): \(.message)"' 2>/dev/null
            errors=$((errors + n))
        fi
    done
    if (( errors > 0 )); then
        fail=1
        echo "   $errors syntax errors"
    else
        echo "   ok (${#qml_files[@]} files)"
    fi
else
    echo "   qmllint not installed, skipped"
fi

echo ":: migrations"
bash "$ROOT/scripts/test-migrations.sh" || fail=1

echo ":: lua"
LUAC=""
for c in luac luac5.4 lua5.4 lua; do
    if command -v "$c" >/dev/null 2>&1; then LUAC="$c"; break; fi
done
if [[ -n $LUAC ]]; then
    lua_fail=0
    while IFS= read -r f; do
        if [[ $LUAC == luac* ]]; then
            "$LUAC" -p "$f" || lua_fail=1
        else
            "$LUAC" -e "assert(loadfile('$f'))" || lua_fail=1
        fi
    done < <(find "$ROOT/hypr" -type f -name '*.lua')
    (( lua_fail )) && fail=1 || echo "   ok"
else
    echo "   lua not installed, skipped"
fi

exit $fail
