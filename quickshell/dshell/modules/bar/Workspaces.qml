pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import qs.config
import qs.services
import qs.components

// Workspace pills for one monitor. Click to switch, scroll to cycle.
Item {
    id: root

    required property ShellScreen screen
    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    readonly property int activeId: monitor?.activeWorkspace?.id ?? -1

    // Workspaces that live on this monitor, plus the fixed count 1..N shown always
    readonly property var ids: {
        const set = new Set();
        for (let i = 1; i <= Config.bar.workspaceCount; i++)
            set.add(i);
        for (const ws of Hypr.workspaces.values) {
            if (ws.id > 0 && ws.monitor?.name === root.screen.name)
                set.add(ws.id);
        }
        if (activeId > 0)
            set.add(activeId);
        return Array.from(set).sort((a, b) => a - b);
    }

    function occupied(id: int): bool {
        const ws = Hypr.workspaces.values.find(w => w.id === id);
        return ws ? ws.toplevels.values.length > 0 : false;
    }

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    StyledRect {
        id: pill
        implicitWidth: row.implicitWidth + Appearance.spacing.small * 2
        implicitHeight: Config.bar.height - Appearance.spacing.normal
        radius: Appearance.rounding.full
        color: Colors.surfaceContainerHigh

        Row {
            id: row
            anchors.centerIn: parent
            spacing: Appearance.spacing.tiny

            Repeater {
                model: root.ids

                Rectangle {
                    id: wsItem
                    required property int modelData
                    readonly property bool active: modelData === root.activeId
                    readonly property bool busy: root.occupied(modelData)

                    width: active ? 32 : 22
                    height: pill.implicitHeight - Appearance.spacing.small
                    radius: Appearance.rounding.full
                    color: active ? Colors.primary : (mouse.containsMouse ? Colors.alpha(Colors.onSurface, 0.1) : "transparent")
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on width {
                        NumberAnimation {
                            duration: Appearance.anim.normal
                            easing.type: Appearance.anim.emphasized
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        visible: Config.bar.workspaceNumbers
                        text: wsItem.modelData
                        font.pointSize: Appearance.fontSize.small
                        font.bold: wsItem.active
                        color: wsItem.active ? Colors.onPrimary : (wsItem.busy ? Colors.onSurface : Colors.onSurfaceVariant)
                    }

                    Rectangle {
                        visible: !Config.bar.workspaceNumbers
                        anchors.centerIn: parent
                        width: wsItem.active ? 10 : 6
                        height: width
                        radius: Appearance.rounding.full
                        color: wsItem.active ? Colors.onPrimary : (wsItem.busy ? Colors.onSurface : Colors.outline)
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hypr.goToWorkspace(wsItem.modelData)
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true
            onWheel: wheel => {
                const dir = wheel.angleDelta.y < 0 ? "+1" : "-1";
                Hypr.dispatch(`focusmonitor ${root.screen.name}`);
                Hypr.dispatch(`workspace m${dir}`);
            }
        }
    }
}
