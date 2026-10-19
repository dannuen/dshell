import QtQuick
import qs.config
import qs.services
import qs.components

// Network, bluetooth and volume icons. Click opens the quick settings sidebar.
StyledRect {
    id: root

    implicitWidth: row.implicitWidth + Appearance.spacing.normal * 2
    implicitHeight: Config.bar.height - Appearance.spacing.normal
    radius: Appearance.rounding.full
    color: Visibilities.sidebar ? Colors.primaryContainer : "transparent"

    readonly property color fg: Visibilities.sidebar ? Colors.onPrimaryContainer : Colors.onSurface

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.normal

        MaterialIcon {
            text: Network.icon
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
        }

        MaterialIcon {
            visible: Bluetooth.enabled
            text: Bluetooth.icon
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
        }

        MaterialIcon {
            text: Audio.icon
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.MiddleButton
                onClicked: Audio.toggleMute()
                onWheel: wheel => Audio.increment(wheel.angleDelta.y > 0 ? Audio.step : -Audio.step)
            }
        }

        MaterialIcon {
            visible: Toggles.nightLight
            text: "nightlight"
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
        }

        MaterialIcon {
            visible: Toggles.caffeine
            text: "coffee"
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    StateLayer {
        onClicked: Visibilities.toggle("sidebar")
        onWheel: wheel => Audio.increment(wheel.angleDelta.y > 0 ? Audio.step : -Audio.step)
    }
}
