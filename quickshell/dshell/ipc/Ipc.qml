import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.services

// Everything Hyprland keybinds call: qs -c dshell ipc call <target> <function>
Item {
    IpcHandler {
        target: "launcher"
        function toggle(): void { Visibilities.toggleLauncher("apps"); }
        function open(mode: string): void { Visibilities.openLauncher(mode); }
        function close(): void { Visibilities.launcher = false; }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { Visibilities.toggleLauncher("clipboard"); }
    }

    IpcHandler {
        target: "windows"
        function toggle(): void { Visibilities.toggleLauncher("windows"); }
    }

    IpcHandler {
        target: "emoji"
        function toggle(): void { Visibilities.toggleLauncher("emoji"); }
    }

    IpcHandler {
        target: "sidebar"
        function toggle(): void { Visibilities.toggle("sidebar"); }
    }

    IpcHandler {
        target: "dashboard"
        function toggle(): void { Visibilities.toggle("dashboard"); }
    }

    IpcHandler {
        target: "session"
        function toggle(): void { Visibilities.toggle("session"); }
    }

    IpcHandler {
        target: "lock"
        function lock(): void { Visibilities.lockRequested(); }
    }

    IpcHandler {
        target: "notifs"
        function toggleHistory(): void { Visibilities.toggle("notifHistory"); }
        function dismissAll(): void { Notifs.hideAllPopups(); }
        function clear(): void { Notifs.clear(); }
        function toggleDnd(): void { Notifs.toggleDnd(); }
    }

    IpcHandler {
        target: "overview"
        function toggle(): void { Visibilities.toggle("overview"); }
    }

    IpcHandler {
        target: "settings"
        function toggle(): void { Visibilities.toggle("settings"); }
    }

    IpcHandler {
        target: "cheatsheet"
        function toggle(): void { Visibilities.toggle("cheatsheet"); }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void { Visibilities.toggle("wallpaper"); }
        function random(): void { Wallpapers.random(); }
        function set(path: string): void { Wallpapers.set(path); }
    }

    IpcHandler {
        target: "theme"
        function toggle(): void { Wallpapers.toggleMode(); }
        function dark(): void { Wallpapers.setMode("dark"); }
        function light(): void { Wallpapers.setMode("light"); }
    }

    IpcHandler {
        target: "volume"
        function increase(): void { Audio.increment(Audio.step); }
        function decrease(): void { Audio.increment(-Audio.step); }
        function mute(): void { Audio.toggleMute(); }
        function micMute(): void { Audio.toggleMicMute(); }
        function set(value: real): void { Audio.setVolume(value); }
    }

    IpcHandler {
        target: "brightness"
        function increase(): void { Brightness.increment(Brightness.step); }
        function decrease(): void { Brightness.increment(-Brightness.step); }
        function set(value: real): void { Brightness.setBrightness(value); }
    }

    IpcHandler {
        target: "media"
        function playPause(): void { Players.playPause(); }
        function next(): void { Players.next(); }
        function previous(): void { Players.previous(); }
    }

    IpcHandler {
        target: "input"
        function toggle(): void { Fcitx.toggle(); }
    }

    IpcHandler {
        target: "shell"
        function closeAll(): void { Visibilities.closeAll(); }
        function reload(): void { Quickshell.reload(true); }
    }
}
