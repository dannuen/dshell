pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Laptop screen brightness through brightnessctl.
Singleton {
    id: root

    property bool available: false
    property real brightness: 1
    property int maxRaw: 1
    readonly property real step: 0.05

    signal changedByUser

    function setBrightness(v: real): void {
        v = Math.max(0.01, Math.min(1, v));
        brightness = v;
        setProc.command = ["brightnessctl", "-q", "s", `${Math.round(v * 100)}%`];
        setProc.running = true;
        changedByUser();
    }

    function increment(delta: real): void {
        setBrightness(brightness + delta);
    }

    function refresh(): void {
        getProc.running = true;
    }

    Process {
        id: getProc
        command: ["sh", "-c", "brightnessctl -m 2>/dev/null | head -n1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                // format: device,class,current,percent%,max
                const parts = text.trim().split(",");
                if (parts.length >= 5) {
                    root.available = true;
                    root.maxRaw = parseInt(parts[4]) || 1;
                    root.brightness = (parseInt(parts[2]) || 0) / root.maxRaw;
                } else {
                    root.available = false;
                }
            }
        }
    }

    Process {
        id: setProc
    }

    // External edits (keys handled by other tools) are picked up every few seconds
    Timer {
        interval: 5000
        running: root.available
        repeat: true
        onTriggered: root.refresh()
    }
}
