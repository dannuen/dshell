pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components

// Bluetooth devices. Discovers while visible.
Column {
    id: root

    readonly property var sorted: {
        const arr = Bluetooth.devices.slice();
        arr.sort((a, b) => (b.connected - a.connected) || ((b.paired || b.bonded) - (a.paired || a.bonded)) || a.name.localeCompare(b.name));
        return arr;
    }

    spacing: Appearance.spacing.tiny
    Component.onCompleted: Bluetooth.setDiscovering(true)
    Component.onDestruction: Bluetooth.setDiscovering(false)

    StyledText {
        visible: !Bluetooth.enabled
        text: "Bluetooth is off"
        color: Colors.onSurfaceVariant
        padding: Appearance.spacing.small
    }

    StyledText {
        visible: Bluetooth.enabled && root.sorted.length === 0
        text: "Searching..."
        color: Colors.onSurfaceVariant
        padding: Appearance.spacing.small
    }

    Repeater {
        model: root.sorted

        StyledRect {
            id: entry
            required property var modelData
            readonly property bool known: modelData.paired || modelData.bonded

            width: root.width
            implicitHeight: 40
            radius: Appearance.rounding.small
            color: modelData.connected ? Colors.secondaryContainer : "transparent"

            StateLayer {
                onClicked: {
                    const d = entry.modelData;
                    if (d.connected)
                        d.disconnect();
                    else if (entry.known)
                        d.connect();
                    else
                        d.pair();
                }
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: Appearance.spacing.normal
                anchors.rightMargin: Appearance.spacing.small
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Bluetooth.deviceIcon(entry.modelData)
                    color: Colors.onSurfaceVariant
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 30 - batt.width - forget.width - parent.spacing * 3
                    text: entry.modelData.name
                    font.weight: entry.modelData.connected ? Font.DemiBold : Font.Normal
                }

                StyledText {
                    id: batt
                    anchors.verticalCenter: parent.verticalCenter
                    visible: entry.modelData.batteryAvailable
                    text: visible ? `${Math.round(entry.modelData.battery * 100)}%` : ""
                    color: Colors.onSurfaceVariant
                    font.pointSize: Appearance.fontSize.small
                }

                IconButton {
                    id: forget
                    anchors.verticalCenter: parent.verticalCenter
                    visible: entry.known
                    icon: "delete"
                    iconSize: Appearance.fontSize.normal
                    tooltip: "Forget"
                    onClicked: entry.modelData.forget()
                }
            }
        }
    }
}
