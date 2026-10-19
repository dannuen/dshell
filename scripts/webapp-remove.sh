#!/usr/bin/env bash

# summary=Remove a web app desktop launcher
# args=[name]

set -e

ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
OLD_ICON_DIR="$HOME/.local/share/applications/icons"
DESKTOP_DIR="$HOME/.local/share/applications/"
PROFILE_BASE_DIR="$HOME/.local/share/webapps"

safe_icon_name() {
  printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//'
}

pick_app() {
  local -a apps=("$@")
  if command -v fzf &>/dev/null; then
    printf '%s\n' "${apps[@]}" | fzf --prompt="Select web app to remove> "
  else
    echo "Select a web app to remove:" >&2
    local choice
    select choice in "${apps[@]}"; do
      if [[ -n $choice ]]; then
        printf '%s\n' "$choice"
        return
      fi
      echo "Invalid selection, try again." >&2
    done
  fi
}

if (( $# == 0 )); then
  # Find all web apps: anything whose Exec launches Brave Origin (or Helium,
  # from an older version of this script) in --app= mode.
  while IFS= read -r -d '' file; do
    if grep -qE '^Exec=.*(brave-origin|brave|helium(-browser)?|net\.imput\.helium).*--app=' "$file"; then
      WEB_APPS+=("$(basename "${file%.desktop}")")
    fi
  done < <(find "$DESKTOP_DIR" -name '*.desktop' -print0)

  if ((${#WEB_APPS[@]})); then
    mapfile -t SORTED_WEB_APPS < <(printf '%s\n' "${WEB_APPS[@]}" | sort)
    APP_NAME=$(pick_app "${SORTED_WEB_APPS[@]}")
  else
    echo "No web apps to remove."
    exit 1
  fi
else
  APP_NAME="$*"
fi

if [[ -z $APP_NAME ]]; then
  echo "You must select a web app to remove."
  exit 1
fi

icon_name=$(safe_icon_name "$APP_NAME")

rm -f "$DESKTOP_DIR/$APP_NAME.desktop"
rm -f "$ICON_DIR/$icon_name.png" "$ICON_DIR/$APP_NAME.png" "$OLD_ICON_DIR/$APP_NAME.png"
rm -rf "${PROFILE_BASE_DIR:?}/$icon_name"

if [[ ${WEBAPP_REMOVE_NOTIFY:-true} != "false" ]]; then
  if command -v notify-send &>/dev/null; then
    notify-send "Web app removed" "$APP_NAME"
  else
    echo "Web app removed: $APP_NAME"
  fi
fi

command -v update-desktop-database &>/dev/null && update-desktop-database "$DESKTOP_DIR" &>/dev/null || true
