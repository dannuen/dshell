#!/usr/bin/env bash
#
# yt-download.sh — Interactive YouTube downloader using yt-dlp
#
# Features:
#   - Choose file type (video / audio-only, and format)
#   - Enter a link (video or playlist)
#   - Choose available quality
#   - If it's a playlist, download the whole playlist with the same choices
#
# Requirements: yt-dlp (and ffmpeg for merging/converting formats)
#
set -uo pipefail

# ---------- Colors ----------
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DOWNLOAD_DIR="${YTDLP_DOWNLOAD_DIR:-$HOME/Downloads}"

# ---------- Helpers ----------
info()  { echo -e "${CYAN}${1}${NC}"; }
ok()    { echo -e "${GREEN}${1}${NC}"; }
warn()  { echo -e "${YELLOW}${1}${NC}"; }
err()   { echo -e "${RED}${1}${NC}" >&2; }

check_dependencies() {
    if ! command -v yt-dlp &>/dev/null || ! command -v ffmpeg &>/dev/null; then
        err "yt-dlp or ffmpeg not found. Install them with: sudo pacman -S --needed ffmpeg yt-dlp (or run install.sh)"
        exit 1
    fi

    ok "Dependencies OK: $(command -v yt-dlp) $( command -v ffmpeg &>/dev/null && echo '| ffmpeg OK' || echo '| ffmpeg MISSING' )"
}

# ---------- Step 1: Get the link ----------
get_link() {
    while true; do
        read -rp "$(echo -e "${BOLD}Enter the YouTube URL (video or playlist):${NC} ")" URL
        if [[ -n "$URL" ]]; then
            break
        else
            err "Please enter a valid URL."
        fi
    done
}

# ---------- Step 2: Detect playlist ----------
detect_playlist() {
    info "Checking the link..."
    # Ask yt-dlp for basic info without downloading
    INFO_JSON=$(yt-dlp --flat-playlist --dump-single-json --no-warnings "$URL" 2>/dev/null)

    if [[ -z "$INFO_JSON" ]]; then
        err "Could not retrieve info for this URL. Check the link and your internet connection."
        exit 1
    fi

    ENTRY_TYPE=$(echo "$INFO_JSON" | grep -o '"_type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
    PLAYLIST_TITLE=$(echo "$INFO_JSON" | grep -o '"title"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
    ENTRY_COUNT=$(echo "$INFO_JSON" | grep -o '"id"[[:space:]]*:' | wc -l)

    if [[ "$ENTRY_TYPE" == "playlist" ]]; then
        IS_PLAYLIST=true
        ok "Detected a PLAYLIST: \"${PLAYLIST_TITLE:-Unknown}\" (~${ENTRY_COUNT} items)"
    else
        IS_PLAYLIST=false
        ok "Detected a SINGLE VIDEO."
    fi
}

# ---------- Step 3: If playlist, ask whether to download whole playlist or just the one video ----------
ask_playlist_scope() {
    if [[ "$IS_PLAYLIST" == true ]]; then
        echo
        echo -e "${BOLD}This link is a playlist. What do you want to download?${NC}"
        echo "  1) The entire playlist  [default]"
        echo "  2) Just this single video/link (no playlist)"
        read -rp "Choice [1-2] (Enter = 1): " scope_choice
        case "$scope_choice" in
            2) PLAYLIST_FLAG="--no-playlist" ;;
            *) PLAYLIST_FLAG="--yes-playlist" ;;
        esac
    else
        PLAYLIST_FLAG="--no-playlist"
    fi
}

# ---------- Step 4: Choose file type ----------
choose_file_type() {
    echo
    echo -e "${BOLD}Choose the file type:${NC}"
    echo "  1) Video (mp4)  [default]"
    echo "  2) Video (mkv - best for combining any codecs)"
    echo "  3) Video (webm)"
    echo "  4) Audio only (mp3)"
    echo "  5) Audio only (m4a)"
    echo "  6) Audio only (best available, original container)"
    read -rp "Choice [1-6] (Enter = 1): " type_choice

    case "$type_choice" in
        "") FILE_TYPE="video"; CONTAINER="mp4" ;;
        1) FILE_TYPE="video"; CONTAINER="mp4" ;;
        2) FILE_TYPE="video"; CONTAINER="mkv" ;;
        3) FILE_TYPE="video"; CONTAINER="webm" ;;
        4) FILE_TYPE="audio"; AUDIO_FORMAT="mp3" ;;
        5) FILE_TYPE="audio"; AUDIO_FORMAT="m4a" ;;
        6) FILE_TYPE="audio"; AUDIO_FORMAT="best" ;;
        *) warn "Invalid choice, defaulting to Video (mp4)."; FILE_TYPE="video"; CONTAINER="mp4" ;;
    esac
}

# ---------- Step 5: List available qualities and choose ----------
choose_quality() {
    if [[ "$FILE_TYPE" == "audio" ]]; then
        echo
        echo -e "${BOLD}Choose audio quality:${NC}"
        echo "  1) Best available  [default]"
        echo "  2) 192 kbps"
        echo "  3) 128 kbps"
        echo "  4) 64 kbps"
        read -rp "Choice [1-4] (Enter = 1): " q_choice
        case "$q_choice" in
            2) AUDIO_QUALITY="192" ;;
            3) AUDIO_QUALITY="128" ;;
            4) AUDIO_QUALITY="64" ;;
            *) AUDIO_QUALITY="0" ;; # 0 = best for yt-dlp --audio-quality
        esac
        return
    fi

    # Video: fetch actual available formats for this specific URL (first item if playlist)
    info "Fetching available video qualities (this may take a few seconds)..."
    FORMATS_RAW=$(yt-dlp --no-playlist -F "$URL" 2>/dev/null)

    # Extract unique resolutions/heights from formats list (rough parse)
    mapfile -t HEIGHTS < <(echo "$FORMATS_RAW" | grep -Eo '[0-9]{3,4}x[0-9]{3,4}' | sed 's/.*x//' | sort -rn -u)

    echo
    echo -e "${BOLD}Available qualities detected for this video:${NC}"
    if [[ ${#HEIGHTS[@]} -eq 0 ]]; then
        warn "Could not detect specific resolutions; falling back to standard options."
        HEIGHTS=(2160 1440 1080 720 480 360 240)
    fi

    echo "  0) Best available  [default]"
    idx=1
    declare -A HEIGHT_MAP
    for h in "${HEIGHTS[@]}"; do
        echo "  ${idx}) ${h}p"
        HEIGHT_MAP[$idx]=$h
        idx=$((idx + 1))
    done
    echo "  ${idx}) Worst/smallest available (fastest download)"
    worst_idx=$idx

    read -rp "Choice (Enter = Best): " q_choice

    if [[ -z "$q_choice" || "$q_choice" == "0" ]]; then
        VIDEO_QUALITY="best"
    elif [[ "$q_choice" == "$worst_idx" ]]; then
        VIDEO_QUALITY="worst"
    elif [[ -n "${HEIGHT_MAP[$q_choice]:-}" ]]; then
        VIDEO_QUALITY="${HEIGHT_MAP[$q_choice]}"
    else
        warn "Invalid choice, defaulting to Best available."
        VIDEO_QUALITY="best"
    fi
}

# ---------- Step 6: Build yt-dlp command ----------
build_and_run() {
    mkdir -p "$DOWNLOAD_DIR"

    if [[ "$PLAYLIST_FLAG" == "--yes-playlist" ]]; then
        # Whole playlist -> its own subfolder named after the playlist, directly under Downloads
        OUTPUT_TEMPLATE="$DOWNLOAD_DIR/%(playlist_title)s/%(title)s.%(ext)s"
    else
        # Single video -> straight into Downloads, no extra subfolder
        OUTPUT_TEMPLATE="$DOWNLOAD_DIR/%(title)s.%(ext)s"
    fi

    CMD=(yt-dlp "$PLAYLIST_FLAG" -o "$OUTPUT_TEMPLATE" --no-mtime --embed-metadata --console-title)

    if [[ "$FILE_TYPE" == "audio" ]]; then
        CMD+=(-x)
        if [[ "$AUDIO_FORMAT" != "best" ]]; then
            CMD+=(--audio-format "$AUDIO_FORMAT")
        fi
        CMD+=(--audio-quality "$AUDIO_QUALITY")
    else
        # Video format selection
        if [[ "$VIDEO_QUALITY" == "best" ]]; then
            FORMAT_STR="bestvideo+bestaudio/best"
        elif [[ "$VIDEO_QUALITY" == "worst" ]]; then
            FORMAT_STR="worstvideo+worstaudio/worst"
        else
            FORMAT_STR="bestvideo[height<=${VIDEO_QUALITY}]+bestaudio/best[height<=${VIDEO_QUALITY}]"
        fi
        CMD+=(-f "$FORMAT_STR" --merge-output-format "$CONTAINER")
    fi

    CMD+=("$URL")

    echo
    info "About to run:"
    echo "  ${CMD[*]}"
    echo
    read -rp "Proceed? [Y/n] (Enter = Yes): " proceed
    if [[ "$proceed" =~ ^[Nn]$ ]]; then
        warn "Cancelled."
        exit 0
    fi

    echo
    "${CMD[@]}"
    result=$?

    echo
    if [[ $result -eq 0 ]]; then
        ok "Download complete! Files saved in: $DOWNLOAD_DIR"
    else
        err "yt-dlp exited with an error (code $result). Scroll up for details."
    fi
}

# ---------- Main ----------
main() {
    echo -e "${BOLD}=== YouTube Downloader (yt-dlp) ===${NC}"
    check_dependencies
    get_link
    detect_playlist
    ask_playlist_scope
    choose_file_type
    choose_quality
    build_and_run
}

main