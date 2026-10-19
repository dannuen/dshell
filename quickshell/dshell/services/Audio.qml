pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property real step: 0.05
    readonly property real maxVolume: 1.0

    // Application output streams for the mixer
    readonly property list<PwNode> streams: Pipewire.nodes.values.filter(n => n.isStream && n.audio && !n.isSink && (n.type & PwNodeType.AudioOutStream))
    readonly property list<PwNode> sinks: Pipewire.nodes.values.filter(n => n.isSink && n.audio && !n.isStream)
    readonly property list<PwNode> sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio && (n.type & PwNodeType.AudioSource))

    readonly property string icon: {
        if (muted || volume === 0)
            return "volume_off";
        if (volume < 0.34)
            return "volume_mute";
        if (volume < 0.67)
            return "volume_down";
        return "volume_up";
    }

    readonly property string micIcon: micMuted ? "mic_off" : "mic"

    signal volumeChangedByUser
    signal micChangedByUser

    function setVolume(v: real): void {
        if (!sink?.audio)
            return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(maxVolume, v));
        volumeChangedByUser();
    }

    function increment(delta: real): void {
        setVolume(volume + delta);
    }

    function toggleMute(): void {
        if (!sink?.audio)
            return;
        sink.audio.muted = !sink.audio.muted;
        volumeChangedByUser();
    }

    function setMicVolume(v: real): void {
        if (!source?.audio)
            return;
        source.audio.volume = Math.max(0, Math.min(1, v));
        micChangedByUser();
    }

    function toggleMicMute(): void {
        if (!source?.audio)
            return;
        source.audio.muted = !source.audio.muted;
        micChangedByUser();
    }

    function setDefaultSink(node: PwNode): void {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node: PwNode): void {
        Pipewire.preferredDefaultAudioSource = node;
    }

    PwObjectTracker {
        objects: [root.sink, root.source, ...root.streams, ...root.sinks, ...root.sources]
    }
}
