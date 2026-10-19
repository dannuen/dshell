pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components

// All workspaces with their windows. Click to focus, drag to move. Super+Tab.
PopupPanel {
    id: root

    name: "overview"
    position: "top"
    dimBackground: true

    content: Component {
        PanelFrame {
            id: frame

            readonly property int cols: 5
            readonly property int rows: 2
            readonly property int count: 10
            readonly property int gap: Appearance.spacing.normal
            // Size of the focused monitor in logical pixels, used for scaling
            readonly property real monW: Math.max(1, (Hypr.focusedMonitor?.width ?? 1920) / (Hypr.focusedMonitor?.scale ?? 1))
            readonly property real monH: Math.max(1, (Hypr.focusedMonitor?.height ?? 1080) / (Hypr.focusedMonitor?.scale ?? 1))
            readonly property real zoom: 0.14
            readonly property int boxW: monW * zoom
            readonly property int boxH: monH * zoom

            // The window being dragged and which box the pointer is over
            property var dragWindow: null
            property int dropTarget: -1

            function workspaceFor(id: int): var {
                return Hypr.workspaces.values.find(w => w.id === id) ?? null;
            }

            function windowsIn(id: int): var {
                return Hypr.toplevels.values.filter(w => w.workspace?.id === id && w.lastIpcObject?.at && w.lastIpcObject?.size);
            }

            function boxAt(px: real, py: real): int {
                for (let i = 0; i < repeater.count; i++) {
                    const b = repeater.itemAt(i);
                    if (!b)
                        continue;
                    const p = grid.mapToItem(frame, b.x, b.y);
                    if (px >= p.x && px < p.x + b.width && py >= p.y && py < p.y + b.height)
                        return i + 1;
                }
                return -1;
            }

            Component.onCompleted: {
                Hypr.monitors;
                Hypr.workspaces;
            }

            Grid {
                id: grid
                columns: frame.cols
                spacing: frame.gap

                Repeater {
                    id: repeater
                    model: frame.count

                    delegate: StyledRect {
                        id: box
                        required property int index
                        readonly property int wsId: index + 1
                        readonly property var ws: frame.workspaceFor(wsId)
                        readonly property bool active: Hypr.focusedWorkspace?.id === wsId
                        readonly property bool hovered: frame.dropTarget === wsId

                        width: frame.boxW
                        height: frame.boxH
                        radius: Appearance.rounding.small
                        color: hovered ? Colors.secondaryContainer : (active ? Colors.surfaceContainerHighest : Colors.surfaceContainerLow)
                        border.width: active ? 2 : 1
                        border.color: active ? Colors.primary : Colors.alpha(Colors.outlineVariant, 0.5)
                        clip: false

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Visibilities.overview = false;
                                Hypr.goToWorkspace(box.wsId);
                            }
                        }

                        StyledText {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 4
                            text: box.wsId
                            font.pointSize: Appearance.fontSize.small
                            color: box.active ? Colors.primary : Colors.onSurfaceVariant
                            z: 2
                        }

                        Repeater {
                            model: frame.windowsIn(box.wsId)

                            delegate: Rectangle {
                                id: win
                                required property var modelData
                                readonly property var ipc: modelData.lastIpcObject
                                readonly property real mx: modelData.monitor?.x ?? 0
                                readonly property real my: modelData.monitor?.y ?? 0
                                readonly property real ms: modelData.monitor?.scale ?? 1
                                // monitor local logical coordinates
                                readonly property real lx: (ipc.at[0] - mx)
                                readonly property real ly: (ipc.at[1] - my)
                                readonly property bool dragging: frame.dragWindow === modelData
                                readonly property string cls: ipc.class ?? ""

                                x: lx * frame.zoom
                                y: ly * frame.zoom
                                width: Math.max(16, ipc.size[0] * frame.zoom)
                                height: Math.max(12, ipc.size[1] * frame.zoom)
                                radius: Appearance.rounding.small / 2
                                color: modelData.activated ? Colors.primaryContainer : Colors.surfaceContainerHigh
                                border.width: 1
                                border.color: Colors.alpha(Colors.outline, 0.6)
                                opacity: dragging ? 0.5 : 1
                                z: dragging ? 10 : (modelData.activated ? 2 : 1)
                                clip: true

                                Column {
                                    anchors.centerIn: parent
                                    width: parent.width - 4
                                    spacing: 2

                                    AppIcon {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        icon: Apps.byId(win.cls)?.icon ?? win.cls
                                        size: Math.min(28, Math.max(12, Math.min(win.width, win.height) * 0.4))
                                    }

                                    StyledText {
                                        width: parent.width
                                        visible: win.height > 34
                                        text: win.modelData.title
                                        font.pointSize: Appearance.fontSize.small - 1
                                        horizontalAlignment: Text.AlignHCenter
                                        color: win.modelData.activated ? Colors.onPrimaryContainer : Colors.onSurfaceVariant
                                    }
                                }

                                MouseArea {
                                    id: dragArea
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                                    cursorShape: Qt.PointingHandCursor
                                    drag.target: win
                                    drag.threshold: 6
                                    preventStealing: true

                                    property bool moved: false

                                    onPressed: {
                                        moved = false;
                                    }

                                    onPositionChanged: mouse => {
                                        if (drag.active) {
                                            moved = true;
                                            frame.dragWindow = win.modelData;
                                            const p = win.mapToItem(frame, mouse.x, mouse.y);
                                            frame.dropTarget = frame.boxAt(p.x, p.y);
                                        }
                                    }

                                    onReleased: mouse => {
                                        const target = frame.dropTarget;
                                        const wasDrag = moved;
                                        frame.dragWindow = null;
                                        frame.dropTarget = -1;
                                        if (wasDrag) {
                                            // snap back; Hyprland sends the new state
                                            win.x = Qt.binding(() => win.lx * frame.zoom);
                                            win.y = Qt.binding(() => win.ly * frame.zoom);
                                            if (target > 0 && target !== box.wsId)
                                                Hypr.moveToWorkspace(win.modelData.address, target);
                                            return;
                                        }
                                        if (mouse.button === Qt.MiddleButton) {
                                            Hypr.closeWindow(win.modelData.address);
                                        } else {
                                            Visibilities.overview = false;
                                            Hypr.focusWindow(win.modelData.address);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
