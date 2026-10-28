#!/usr/bin/env bash
# ~/.config/fcitx5 used to be a symlink into the repo. fcitx5 rewrites its
# files, which made git pull fail, so replace the link with a real copy.
DIR="$HOME/.config/fcitx5"
if [[ -L $DIR ]]; then
    tmp="$DIR.tmp.$$"
    cp -rL "$DIR" "$tmp" && rm -f "$DIR" && mv "$tmp" "$DIR"
fi
