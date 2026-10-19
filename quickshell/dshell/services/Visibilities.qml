pragma Singleton

import Quickshell
import QtQuick

// Which panel is open. Panels that take the keyboard are exclusive:
// opening one closes the others.
Singleton {
    id: root

    property bool launcher: false
    property bool sidebar: false
    property bool dashboard: false
    property bool session: false
    property bool notifHistory: false
    property bool overview: false
    property bool settings: false
    property bool cheatsheet: false
    property bool wallpaper: false
    property bool osd: false
    property bool locked: false

    signal lockRequested

    // Launcher mode asked for by IPC: "apps", "clipboard", "windows", "emoji"
    property string launcherMode: "apps"

    readonly property list<string> exclusive: ["launcher", "sidebar", "dashboard", "session", "notifHistory", "overview", "settings", "cheatsheet", "wallpaper"]

    readonly property bool anyOpen: exclusive.some(n => root[n])

    function closeAll(): void {
        for (const n of exclusive)
            root[n] = false;
    }

    function open(name: string): void {
        for (const n of exclusive)
            root[n] = (n === name);
    }

    function toggle(name: string): void {
        if (root[name])
            root[name] = false;
        else
            open(name);
    }

    function openLauncher(mode: string): void {
        launcherMode = mode;
        open("launcher");
    }

    function toggleLauncher(mode: string): void {
        if (launcher && launcherMode === mode) {
            launcher = false;
        } else {
            launcherMode = mode;
            open("launcher");
        }
    }
}
