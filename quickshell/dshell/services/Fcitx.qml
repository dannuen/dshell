pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

// Current input method from fcitx5. Shows EN or VI in the bar.
Singleton {
    id: root

    property string im: "keyboard-us"
    property bool available: false
    readonly property bool vietnamese: im !== "" && !im.startsWith("keyboard")
    readonly property string label: vietnamese ? "VI" : "EN"

    signal changed

    function toggle(): void {
        Quickshell.execDetached(["fcitx5-remote", "-t"]);
        pollTimer.restart();
        quickPoll.start();
    }

    Process {
        id: proc
        command: ["fcitx5-remote", "-n"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim();
                root.available = v.length > 0;
                if (v !== root.im) {
                    root.im = v;
                    root.changed();
                }
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 1000
        running: Config.bar.showInputMethod
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Timer {
        id: quickPoll
        interval: 120
        onTriggered: proc.running = true
    }
}
