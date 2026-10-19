pragma Singleton

import Quickshell
import Quickshell.Hyprland
import QtQuick

// Small helpers around the Hyprland IPC module.
Singleton {
    id: root

    readonly property var monitors: Hyprland.monitors
    readonly property var workspaces: Hyprland.workspaces
    readonly property var toplevels: Hyprland.toplevels
    readonly property HyprlandMonitor focusedMonitor: Hyprland.focusedMonitor
    readonly property HyprlandWorkspace focusedWorkspace: Hyprland.focusedWorkspace
    readonly property HyprlandToplevel activeToplevel: Hyprland.activeToplevel
    readonly property string focusedScreenName: focusedMonitor?.name ?? ""

    function dispatch(request: string): void {
        Hyprland.dispatch(request);
    }

    function monitorFor(screen: var): HyprlandMonitor {
        return Hyprland.monitorFor(screen);
    }

    function goToWorkspace(id: int): void {
        Hyprland.dispatch(`workspace ${id}`);
    }

    function focusWindow(address: string): void {
        Hyprland.dispatch(`focuswindow address:${address}`);
    }

    function closeWindow(address: string): void {
        Hyprland.dispatch(`closewindow address:${address}`);
    }

    function moveToWorkspace(address: string, id: int): void {
        Hyprland.dispatch(`movetoworkspacesilent ${id},address:${address}`);
    }

    function exec(cmd: string): void {
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            const n = event.name;
            if (n.endsWith("v2"))
                return;
            if (["openwindow", "closewindow", "movewindow", "windowtitle", "activewindow", "fullscreen", "changefloatingmode"].includes(n))
                Hyprland.refreshToplevels();
            if (["createworkspace", "destroyworkspace", "moveworkspace", "renameworkspace", "workspace", "focusedmon"].includes(n))
                Hyprland.refreshWorkspaces();
            if (["monitoradded", "monitorremoved", "focusedmon"].includes(n))
                Hyprland.refreshMonitors();
        }
    }
}
