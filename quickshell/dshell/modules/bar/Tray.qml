pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.config
import qs.services
import qs.components

// System tray icons with their menus.
Row {
    id: root

    required property var bar
    spacing: Appearance.spacing.tiny
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        Item {
            id: item
            required property SystemTrayItem modelData

            width: 26
            height: 26

            IconImage {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: item.modelData.icon
                asynchronous: true
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: item.modelData.menu
                anchor.window: root.bar
                anchor.item: item
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton || (mouse.button === Qt.LeftButton && item.modelData.onlyMenu)) {
                        if (item.modelData.hasMenu)
                            menuAnchor.open();
                    } else if (mouse.button === Qt.MiddleButton) {
                        item.modelData.secondaryActivate();
                    } else {
                        item.modelData.activate();
                    }
                }
                onWheel: wheel => item.modelData.scroll(wheel.angleDelta.y, false)
            }

            Tooltip {
                text: item.modelData.tooltipTitle || item.modelData.title || item.modelData.id
                visible: text !== "" && hover.containsMouse
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
            }
        }
    }
}
