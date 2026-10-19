#!/usr/bin/env bash
# The fcitx5 profile is no longer in the repo (fcitx5 rewrites it, and it
# depends on whether lotus or bamboo is installed). Pulling this change
# deletes the old one, so make a new one.
REPO="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.." && pwd)"
bash "$REPO/scripts/fcitx5-profile.sh"
