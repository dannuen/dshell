pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

// Wallpaper list and the matugen theming pipeline.
// scripts/wallpaper.sh does the heavy work so it can also run from a terminal.
Singleton {
    id: root

    readonly property bool ready: true
    property list<string> list: []
    readonly property string current: Config.wallpaper.current
    readonly property string scriptDir: Quickshell.shellDir + "/../../scripts"
    property bool busy: false

    function refresh(): void {
        listProc.running = true;
    }

    function set(path: string): void {
        if (!path || busy)
            return;
        busy = true;
        setProc.command = [`${scriptDir}/wallpaper.sh`, "set", path];
        setProc.running = true;
    }

    function random(): void {
        if (list.length === 0)
            return;
        set(list[Math.floor(Math.random() * list.length)]);
    }

    function setMode(mode: string): void {
        Config.theme.mode = mode;
        Config.save();
        if (current)
            set(current);
    }

    function toggleMode(): void {
        setMode(Config.theme.mode === "dark" ? "light" : "dark");
    }

    Process {
        id: listProc
        command: ["sh", "-c", `find "${Config.wallpaper.dir}" -maxdepth 2 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort`]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.list = text.trim().split("\n").filter(l => l.length > 0)
        }
    }

    Process {
        id: setProc
        onRunningChanged: if (!running)
            root.busy = false
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim();
                if (p.length > 0) {
                    Config.wallpaper.current = p;
                    Config.save();
                }
            }
        }
    }

    Connections {
        target: Config.wallpaper
        function onDirChanged(): void {
            root.refresh();
        }
    }
}
