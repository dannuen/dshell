#!/usr/bin/env bash
# dshell installer for CachyOS and Arch.
# Run as your normal user. It asks for sudo when it needs it.
#
#   ./install.sh [--no-update] [--no-aur] [--copy] [--dry-run] [-h]
#
# --no-update  skip the full system update (pacman -Syu)
# --no-aur     skip AUR packages (quickshell-git, matugen, fonts ...)
# --copy       copy files into ~/.config instead of symlinking them
# --dry-run    only print what would happen
set -euo pipefail

REPO="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"
CONFIG="$HOME/.config"
STATE="$HOME/.local/state/dshell"
BACKUP="$CONFIG/dshell-backup-$(date +%Y%m%d-%H%M%S)"
DO_UPDATE=1
DO_AUR=1
COPY=0
DRY=0

info() { printf '\e[1;34m::\e[0m %s\n' "$*"; }
ok()   { printf '\e[1;32m ok\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m !!\e[0m %s\n' "$*"; }
die()  { printf '\e[1;31m xx\e[0m %s\n' "$*" >&2; exit 1; }

run() {
    if (( DRY )); then
        printf '   [dry] %s\n' "$*"
    else
        "$@"
    fi
}

usage() {
    sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --no-update) DO_UPDATE=0 ;;
        --no-aur) DO_AUR=0 ;;
        --copy) COPY=1 ;;
        --dry-run) DRY=1 ;;
        -h|--help) usage ;;
        *) die "unknown option: $arg" ;;
    esac
done

# ---------------------------------------------------------------- 1. checks
[[ $EUID -eq 0 ]] && die "Run this as your normal user, not root."
command -v pacman >/dev/null 2>&1 || die "pacman not found. dshell needs CachyOS or Arch."
if [[ -r /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    case "${ID:-} ${ID_LIKE:-}" in
        *arch*|*cachyos*) ;;
        *) die "This looks like '${ID:-unknown}', not Arch or CachyOS." ;;
    esac
fi
command -v sudo >/dev/null 2>&1 || die "sudo is needed."
info "dshell installer, repo at $REPO"

# ---------------------------------------------------------------- 2. update
if (( DO_UPDATE )); then
    info "Full system update (this also brings Hyprland to the latest version)"
    run sudo pacman -Syu --noconfirm
else
    warn "Skipping system update (--no-update)"
fi

# ---------------------------------------------------------------- 3. pacman packages
read_list() {
    grep -vE '^\s*(#|$)' "$1" | awk '{print $1}'
}

mapfile -t PKGS < <(read_list "$REPO/packages.txt")
mapfile -t AUR_PKGS < <(read_list "$REPO/packages-aur.txt")

info "Checking ${#PKGS[@]} pacman packages"
REPO_PKGS=()
for p in "${PKGS[@]}"; do
    if pacman -Si "$p" >/dev/null 2>&1; then
        REPO_PKGS+=("$p")
    else
        warn "$p is not in the repos, will try the AUR"
        AUR_PKGS+=("$p")
    fi
done
if (( ${#REPO_PKGS[@]} )); then
    info "Installing pacman packages"
    run sudo pacman -S --needed --noconfirm "${REPO_PKGS[@]}"
fi

# ---------------------------------------------------------------- 4. AUR
if (( DO_AUR )); then
    HELPER=""
    command -v paru >/dev/null 2>&1 && HELPER=paru
    [[ -z $HELPER ]] && command -v yay >/dev/null 2>&1 && HELPER=yay
    if [[ -z $HELPER ]]; then
        info "No AUR helper found, installing paru"
        run sudo pacman -S --needed --noconfirm base-devel git
        TMP="$(mktemp -d)"
        run git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$TMP/paru-bin"
        if (( ! DRY )); then
            (cd "$TMP/paru-bin" && makepkg -si --noconfirm)
        fi
        rm -rf "$TMP"
        HELPER=paru
    fi
    info "Installing AUR packages with $HELPER"
    for p in "${AUR_PKGS[@]}"; do
        if ! run "$HELPER" -S --needed --noconfirm "$p"; then
            if [[ $p == fcitx5-lotus ]]; then
                warn "fcitx5-lotus failed, trying fcitx5-bamboo"
                run "$HELPER" -S --needed --noconfirm fcitx5-bamboo || warn "fcitx5-bamboo failed too. Install one of them by hand."
            else
                warn "$p failed to install. Install it by hand later."
            fi
        fi
    done
else
    warn "Skipping AUR packages (--no-aur). quickshell-git and matugen are needed for the shell."
fi

# ---------------------------------------------------------------- 5. Hyprland version
HV=""
if command -v Hyprland >/dev/null 2>&1; then
    HV="$(Hyprland --version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1 | tr -d v || true)"
fi
if [[ -z $HV ]] && command -v hyprctl >/dev/null 2>&1; then
    HV="$(hyprctl version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1 | tr -d v || true)"
fi
if [[ -n $HV ]]; then
    MAJOR="${HV%%.*}"
    MINOR="$(echo "$HV" | cut -d. -f2)"
    if (( MAJOR == 0 && MINOR < 55 )); then
        die "Hyprland $HV found. Hyprland 0.55 or newer is needed for the Lua config. Run a full system update and try again."
    fi
    ok "Hyprland $HV"
else
    warn "Could not read the Hyprland version. Make sure it is 0.55 or newer."
fi

# ---------------------------------------------------------------- 6. backup
# Returns 0 when the path is a symlink that already points into this repo.
links_into_repo() {
    [[ -L $1 ]] || return 1
    local target
    target="$(realpath -m "$1" 2>/dev/null || true)"
    [[ $target == "$REPO"/* ]]
}

backup() {
    local path="$1"
    [[ -e $path || -L $path ]] || return 0
    if links_into_repo "$path"; then
        run rm -f "$path"
        return 0
    fi
    local rel="${path#"$CONFIG"/}"
    run mkdir -p "$BACKUP/$(dirname "$rel")"
    run mv "$path" "$BACKUP/$rel"
    ok "backed up $path"
}

info "Backing up old configs to $BACKUP"
for t in "$CONFIG/hypr" "$CONFIG/quickshell/dshell" "$CONFIG/kitty" "$CONFIG/fish/config.fish" \
         "$CONFIG/starship.toml" "$CONFIG/fcitx5" "$CONFIG/fastfetch"; do
    backup "$t"
done
# settings.json is kept, but copied to the backup for safety
if [[ -f "$CONFIG/dshell/settings.json" ]]; then
    run mkdir -p "$BACKUP/dshell"
    run cp "$CONFIG/dshell/settings.json" "$BACKUP/dshell/settings.json"
fi
if (( ! DRY )) && [[ ! -d $BACKUP ]]; then
    ok "nothing to back up"
fi

# ---------------------------------------------------------------- 7. link
place() {
    # place <source in repo> <target path>
    local src="$1" dst="$2"
    run mkdir -p "$(dirname "$dst")"
    if (( COPY )); then
        run cp -r "$src" "$dst"
    else
        run ln -sfn "$src" "$dst"
    fi
}

info "Installing configs ($( (( COPY )) && echo copies || echo symlinks ))"
# scripts are reached as ~/.config/hypr/scripts
if (( COPY )); then
    place "$REPO/hypr" "$CONFIG/hypr"
    run rm -rf "$CONFIG/hypr/scripts"
    run cp -r "$REPO/scripts" "$CONFIG/hypr/scripts"
else
    run ln -sfn "$REPO/scripts" "$REPO/hypr/scripts"
    place "$REPO/hypr" "$CONFIG/hypr"
fi
place "$REPO/quickshell/dshell" "$CONFIG/quickshell/dshell"
place "$REPO/dotfiles/kitty" "$CONFIG/kitty"
place "$REPO/dotfiles/fish/config.fish" "$CONFIG/fish/config.fish"
place "$REPO/dotfiles/starship/starship.toml" "$CONFIG/starship.toml"
place "$REPO/dotfiles/fcitx5" "$CONFIG/fcitx5"
place "$REPO/dotfiles/fastfetch" "$CONFIG/fastfetch"

run mkdir -p "$CONFIG/dshell/templates" "$STATE" "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots" \
    "$CONFIG/gtk-3.0" "$CONFIG/gtk-4.0"
run cp "$REPO/templates/matugen-config.toml" "$CONFIG/dshell/matugen.toml"
for f in colors.json hyprland-colors.lua kitty-colors.conf gtk.css; do
    run cp "$REPO/templates/$f" "$CONFIG/dshell/templates/$f"
done
if [[ ! -f "$CONFIG/dshell/settings.json" ]]; then
    if (( DRY )); then
        printf '   [dry] write %s\n' "$CONFIG/dshell/settings.json"
    else
        echo '{}' > "$CONFIG/dshell/settings.json"
    fi
fi
# kitty needs colors.conf to exist even before matugen ran
if (( ! DRY )) && [[ ! -f "$CONFIG/kitty/colors.conf" ]]; then
    touch "$CONFIG/kitty/colors.conf" 2>/dev/null || true
fi
run chmod +x "$REPO"/scripts/*.sh
ok "configs in place"

# ---------------------------------------------------------------- 8. services
info "Enabling services"
for s in NetworkManager bluetooth power-profiles-daemon; do
    run sudo systemctl enable --now "$s" >/dev/null 2>&1 || warn "could not enable $s"
done
run systemctl --user enable --now hyprpolkitagent >/dev/null 2>&1 || warn "could not enable hyprpolkitagent (fine if not logged into Hyprland yet)"

# ---------------------------------------------------------------- 8b. fonts
info "Checking fonts"
if (( DRY )); then
    printf '   [dry] %s/scripts/fonts.sh\n' "$REPO"
else
    bash "$REPO/scripts/fonts.sh" || warn "icon font missing. Run: bash $REPO/scripts/fonts.sh"
fi

# ---------------------------------------------------------------- 9. GTK
if command -v gsettings >/dev/null 2>&1; then
    info "Setting GTK dark theme"
    run gsettings set org.gnome.desktop.interface color-scheme prefer-dark || true
    run gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark || true
    run gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark || true
    run gsettings set org.gnome.desktop.interface font-name "CaskaydiaCove Nerd Font 10" || true
fi

# ---------------------------------------------------------------- 10. first colors
info "Building the first color scheme"
if (( DRY )); then
    printf '   [dry] DSHELL_NO_WALLPAPER=1 %s/scripts/wallpaper.sh restore\n' "$REPO"
else
    DSHELL_NO_WALLPAPER=1 "$REPO/scripts/wallpaper.sh" restore >/dev/null || warn "color scheme not built yet (matugen missing?). It runs again at login."
fi

# ---------------------------------------------------------------- 11. done
echo
ok "dshell is installed."
[[ -d $BACKUP ]] && echo "   Old configs: $BACKUP"
cat <<MSG

   Next: log out, pick Hyprland in SDDM, and log in.

   Super+Space   launcher        Super+/      keybind cheat sheet
   Super+A       quick settings  Super+D      dashboard
   Super+W       wallpaper       Super+Escape session menu

   Put wallpapers in ~/Pictures/Wallpapers.
   Shell errors: run 'qs -c dshell' in a terminal.
   Icons show as text: bash $REPO/scripts/fonts.sh
   Fish as default shell: chsh -s /usr/bin/fish
MSG
