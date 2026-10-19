#!/usr/bin/env bash

# summary=Create a desktop launcher for a web app (opens with Brave)
# args=[name url icon-url-or-name [custom-exec] [mime-types]]

set -e

ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
PROFILE_BASE_DIR="$HOME/.local/share/webapps"

# Find the Brave Origin binary under whatever name it was installed as.
find_brave_bin() {
  for candidate in brave-origin brave; do
    if command -v "$candidate" &>/dev/null; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

# Install Brave Origin using whatever mechanism fits this system, then confirm
# it actually landed on PATH. Prefers native distro packages (kept up to date
# by the system package manager); falls back to the official portable .zip
# release under ~/.local/opt for anything else, which needs no root.
install_brave_origin() {
  echo "Brave Origin not found — installing it as a dependency..." >&2

  if [[ $EUID -ne 0 ]] && command -v sudo &>/dev/null; then
    SUDO="sudo"
  elif [[ $EUID -eq 0 ]]; then
    SUDO=""
  else
    SUDO="" # no root and no sudo; native package managers below will just fail and we'll fall through to the zip release
  fi

  if command -v pacman &>/dev/null; then
    # Arch based: install from the AUR via whatever helper is present.
    for helper in yay paru; do
      if command -v "$helper" &>/dev/null; then
        "$helper" -S --noconfirm --needed brave-origin-bin && return 0
        break
      fi
    done
    echo "No AUR helper (yay/paru) found — falling back to portable install." >&2

  elif command -v apt &>/dev/null || command -v apt-get &>/dev/null; then
    local apt_bin=apt
    command -v apt &>/dev/null || apt_bin=apt-get
    $SUDO curl -fsSL -o /usr/share/keyrings/brave-browser-archive-keyring.gpg \
      https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg &&
      $SUDO curl -fsSL -o /etc/apt/sources.list.d/brave-browser-release.sources \
        https://brave-browser-apt-release.s3.brave.com/brave-browser.sources &&
      $SUDO "$apt_bin" update &&
      $SUDO "$apt_bin" install -y brave-origin && return 0
    echo "apt-based install failed — falling back to portable install." >&2

  elif command -v dnf &>/dev/null; then
    $SUDO dnf install -y dnf-plugins-core &&
      $SUDO dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo &&
      $SUDO dnf install -y brave-origin && return 0
    echo "dnf-based install failed — falling back to portable install." >&2
  fi

  # Universal fallback: official portable .zip release, no root required.
  # (Brave doesn't publish an AppImage, unlike Helium — the zip is the
  # closest no-install-required equivalent and is an official artifact.)
  echo "Installing Brave Origin as a portable build in ~/.local/opt..." >&2
  local opt_dir="$HOME/.local/opt/brave-origin"
  local bin_dir="$HOME/.local/bin"
  mkdir -p "$opt_dir" "$bin_dir"

  local arch zip_url
  case "$(uname -m)" in
  x86_64) arch="amd64" ;;
  aarch64 | arm64) arch="arm64" ;;
  *)
    echo "Error: no portable build available for architecture $(uname -m)." >&2
    return 1
    ;;
  esac

  zip_url=$(curl -fsSL --max-time 15 https://api.github.com/repos/brave/brave-browser/releases/latest 2>/dev/null |
    grep -oE "\"browser_download_url\": *\"[^\"]*brave-origin[^\"]*${arch}\.zip\"" |
    head -1 | sed -E 's/.*"(https[^"]+)"/\1/')

  if [[ -z $zip_url ]]; then
    echo "Error: could not resolve the latest Brave Origin .zip download URL." >&2
    return 1
  fi

  local tmp_zip
  tmp_zip=$(mktemp --suffix=.zip)
  if ! curl -fsSL --max-time 180 -o "$tmp_zip" "$zip_url"; then
    echo "Error: failed to download Brave Origin .zip release." >&2
    rm -f "$tmp_zip"
    return 1
  fi

  if ! command -v unzip &>/dev/null; then
    echo "Error: 'unzip' is required to install the portable Brave Origin build." >&2
    rm -f "$tmp_zip"
    return 1
  fi

  rm -rf "${opt_dir:?}"/*
  unzip -q "$tmp_zip" -d "$opt_dir"
  rm -f "$tmp_zip"

  local brave_exe
  brave_exe=$(find "$opt_dir" -maxdepth 2 -type f -iname 'brave*' -perm -u+x | head -1)
  if [[ -z $brave_exe ]]; then
    echo "Error: could not locate the Brave Origin executable after extraction." >&2
    return 1
  fi

  ln -sf "$brave_exe" "$bin_dir/brave-origin"

  case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) echo "Note: add $bin_dir to your PATH to run 'brave-origin' directly." >&2 ;;
  esac
}

safe_icon_name() {
  printf '%s\n' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//'
}

icon_name_from_ref() {
  local ref="$1"
  local name
  name=$(basename "$ref")

  if [[ $name == *.* ]]; then
    safe_icon_name "${name%.*}"
  else
    printf '%s\n' "$name"
  fi
}

install_user_icon() {
  local source="$1"
  local name="$2"
  local ext="${source##*.}"

  [[ $ext == "$source" ]] && ext="png"
  mkdir -p "$ICON_DIR"
  cp "$source" "$ICON_DIR/$name.$ext"
  gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" &>/dev/null || true
  printf '%s\n' "$name"
}

download_icon() {
  curl -fsSL --max-time 10 -o "$2" "$1" 2>/dev/null &&
    [[ -s $2 && $(file -b --mime-type "$2") == image/* ]]
}

fetch_site_icon() {
  local site_url="$1" dest="$2"
  local origin page icon_url
  origin=$(sed -E 's|^(https?://[^/]+).*|\1|' <<<"$site_url")

  # Prefer the site's own high-res icon (apple-touch-icon is typically 180px+),
  # then the well-known path, then Google's favicon service as a last resort.
  page=$(curl -fsSL --max-time 5 "$site_url" 2>/dev/null | head -c 100000 | tr '\n' ' ')
  icon_url=$(grep -oiE "<link[^>]*rel=[\"'][^\"']*apple-touch-icon[^\"']*[\"'][^>]*>" <<<"$page" |
    grep -oiE "href=[\"'][^\"']+" | head -1 | sed -E "s/^href=[\"']//")

  case $icon_url in
  http://* | https://*) ;;
  //*) icon_url="https:$icon_url" ;;
  /*) icon_url="$origin$icon_url" ;;
  ?*) icon_url="$origin/$icon_url" ;;
  esac

  { [[ -n $icon_url ]] && download_icon "$icon_url" "$dest"; } ||
    download_icon "$origin/apple-touch-icon.png" "$dest" ||
    download_icon "https://www.google.com/s2/favicons?domain=${site_url}&sz=256" "$dest"
}

# Locate Brave Origin up front, installing it automatically if it's missing.
if ! BRAVE_BIN=$(find_brave_bin); then
  if install_brave_origin; then
    # ~/.local/bin may not be on PATH yet in this shell; check it explicitly
    # before giving up, since install_brave_origin may have just placed it there.
    if ! BRAVE_BIN=$(find_brave_bin); then
      hash -r
      if [[ -x "$HOME/.local/bin/brave-origin" ]]; then
        BRAVE_BIN="$HOME/.local/bin/brave-origin"
      fi
    fi
  fi

  if [[ -z ${BRAVE_BIN:-} ]]; then
    echo "Error: Brave Origin could not be found or installed automatically." >&2
    echo "Install it yourself from https://brave.com/origin/linux/ and re-run this script." >&2
    exit 1
  fi
fi

if (( $# < 3 )); then
  if command -v gum &>/dev/null; then
    echo -e "\e[32mLet's create a new web app you can start with the app launcher.\n\e[0m"
    APP_NAME=$(gum input --prompt "Name> " --placeholder "My favorite web app")
    APP_URL=$(gum input --prompt "URL> " --placeholder "https://example.com")
  else
    echo "Let's create a new web app you can start with the app launcher."
    read -rp "Name> " APP_NAME
    read -rp "URL> " APP_URL
  fi

  if [[ ! $APP_URL =~ ^[a-zA-Z][a-zA-Z0-9+.-]*: ]]; then
    APP_URL="https://$APP_URL"
  fi

  # Try to fetch the site's icon automatically first.
  mkdir -p "$ICON_DIR"
  ICON_VALUE=$(safe_icon_name "$APP_NAME")
  if fetch_site_icon "$APP_URL" "$ICON_DIR/$ICON_VALUE.png"; then
    gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" &>/dev/null || true
    ICON_REF="$ICON_VALUE"
  else
    if command -v gum &>/dev/null; then
      ICON_REF=$(gum input --prompt "Icon URL/name> " --placeholder "Could not fetch favicon automatically. Enter PNG icon URL or icon name")
    else
      read -rp "Icon URL/name (favicon fetch failed)> " ICON_REF
    fi
  fi

  CUSTOM_EXEC=""
  MIME_TYPES=""
  INTERACTIVE_MODE=true
else
  APP_NAME="$1"
  APP_URL="$2"
  if [[ ! $APP_URL =~ ^[a-zA-Z][a-zA-Z0-9+.-]*: ]]; then
    APP_URL="https://$APP_URL"
  fi
  ICON_REF="$3"
  CUSTOM_EXEC="$4" # Optional custom exec command
  MIME_TYPES="$5"  # Optional mime types
  INTERACTIVE_MODE=false
fi

# Ensure valid execution
if [[ -z $APP_NAME || -z $APP_URL ]]; then
  echo "You must set app name and app URL!"
  exit 1
fi

if [[ -z $ICON_REF ]]; then
  ICON_VALUE=$(safe_icon_name "$APP_NAME")
  mkdir -p "$ICON_DIR"
  if ! fetch_site_icon "$APP_URL" "$ICON_DIR/$ICON_VALUE.png"; then
    echo "Error: Failed to download icon."
    exit 1
  fi
  gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" &>/dev/null || true
elif [[ $ICON_REF =~ ^https?:// ]]; then
  ICON_VALUE=$(safe_icon_name "$APP_NAME")
  mkdir -p "$ICON_DIR"
  if ! download_icon "$ICON_REF" "$ICON_DIR/$ICON_VALUE.png"; then
    echo "Error: Failed to download icon."
    exit 1
  fi
  gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" &>/dev/null || true
elif [[ -f $ICON_REF ]]; then
  ICON_VALUE=$(install_user_icon "$ICON_REF" "$(safe_icon_name "$APP_NAME")")
else
  # Allow passing a bare icon theme name (e.g. "web-app-icon" or "HEY"/"HEY.png").
  ICON_VALUE=$(icon_name_from_ref "$ICON_REF")
fi

# Give each webapp its own Chromium/Brave profile so cookies, logins, and
# extensions stay isolated per-app instead of bleeding into your main profile.
APP_SLUG=$(safe_icon_name "$APP_NAME")
PROFILE_DIR="$PROFILE_BASE_DIR/$APP_SLUG"
mkdir -p "$PROFILE_DIR"

# Use custom exec if provided, otherwise launch Brave Origin directly in app mode.
EXEC_COMMAND="${CUSTOM_EXEC:-$BRAVE_BIN --app=\"$APP_URL\" --user-data-dir=\"$PROFILE_DIR\" --name=\"$APP_NAME\" --class=\"$APP_SLUG\"}"

# Create application .desktop file
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=$EXEC_COMMAND
Terminal=false
Type=Application
Icon=$ICON_VALUE
StartupNotify=true
StartupWMClass=$APP_SLUG
EOF

# Add mime types if provided
if [[ -n $MIME_TYPES ]]; then
  echo "MimeType=$MIME_TYPES" >>"$DESKTOP_FILE"
fi

chmod +x "$DESKTOP_FILE"

command -v update-desktop-database &>/dev/null && update-desktop-database "$HOME/.local/share/applications" &>/dev/null || true

if [[ $INTERACTIVE_MODE == "true" ]]; then
  echo -e "You can now find $APP_NAME in your app launcher.\n"
fi
