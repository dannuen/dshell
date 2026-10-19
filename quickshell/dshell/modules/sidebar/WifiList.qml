pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Networking
import qs.config
import qs.services
import qs.components

// Nearby Wi-Fi networks. Scans while visible.
Column {
    id: root

    property var pendingNetwork: null

    readonly property var sorted: {
        const arr = Network.networks.slice();
        arr.sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength));
        return arr;
    }

    spacing: Appearance.spacing.tiny
    Component.onCompleted: Network.scan(true)
    Component.onDestruction: Network.scan(false)

    StyledText {
        visible: !Network.wifiEnabled
        text: "Wi-Fi is off"
        color: Colors.fgSurfaceVariant
        padding: Appearance.spacing.small
    }

    StyledText {
        visible: Network.wifiEnabled && root.sorted.length === 0
        text: "Searching..."
        color: Colors.fgSurfaceVariant
        padding: Appearance.spacing.small
    }

    Repeater {
        model: root.sorted

        Column {
            id: entry
            required property WifiNetwork modelData
            width: root.width
            spacing: Appearance.spacing.tiny

            StyledRect {
                width: parent.width
                implicitHeight: 40
                radius: Appearance.rounding.small
                color: entry.modelData.connected ? Colors.secondaryContainer : "transparent"

                StateLayer {
                    onClicked: {
                        const n = entry.modelData;
                        if (n.connected) {
                            n.disconnect();
                        } else if (n.known || n.security === WifiSecurityType.Open) {
                            Network.connect(n, "");
                        } else {
                            root.pendingNetwork = (root.pendingNetwork === n) ? null : n;
                        }
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.spacing.normal
                    anchors.rightMargin: Appearance.spacing.normal
                    spacing: Appearance.spacing.normal

                    MaterialIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Network.strengthIcon(entry.modelData.signalStrength)
                        color: Colors.fgSurfaceVariant
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 30 * 2 - parent.spacing * 2
                        text: entry.modelData.name
                        font.weight: entry.modelData.connected ? Font.DemiBold : Font.Normal
                    }

                    MaterialIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: entry.modelData.connected ? "check" : (entry.modelData.security !== WifiSecurityType.Open ? "lock" : "")
                        color: Colors.fgSurfaceVariant
                        font.pointSize: Appearance.fontSize.normal
                    }
                }
            }

            StyledTextField {
                visible: root.pendingNetwork === entry.modelData
                width: parent.width
                implicitHeight: 40
                icon: "key"
                password: true
                placeholder: "Password"
                onVisibleChanged: if (visible) focusInput()
                onAccepted: {
                    Network.connect(entry.modelData, text);
                    text = "";
                    root.pendingNetwork = null;
                }
            }
        }
    }
}
