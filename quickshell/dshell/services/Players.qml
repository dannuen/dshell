pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    readonly property list<MprisPlayer> list: Mpris.players.values
    property MprisPlayer manual: null

    // Playing player first, then the manual pick, then the first one
    readonly property MprisPlayer active: {
        if (manual && list.includes(manual))
            return manual;
        return list.find(p => p.isPlaying) ?? list[0] ?? null;
    }

    readonly property bool playing: active?.isPlaying ?? false
    readonly property string title: active?.trackTitle ?? ""
    readonly property string artist: active?.trackArtist ?? ""
    readonly property string artUrl: active?.trackArtUrl ?? ""

    function playPause(): void {
        if (active?.canTogglePlaying)
            active.togglePlaying();
    }

    function next(): void {
        if (active?.canGoNext)
            active.next();
    }

    function previous(): void {
        if (active?.canGoPrevious)
            active.previous();
    }
}
