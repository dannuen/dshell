import QtQuick
import qs.config
import qs.services
import qs.components

StyledRect {
    id: root

    implicitWidth: row.implicitWidth + Appearance.spacing.normal * 2
    implicitHeight: Config.bar.height - Appearance.spacing.normal
    radius: Appearance.rounding.full
    color: Battery.critical ? Colors.errorContainer : (Battery.low ? Colors.tertiaryContainer : "transparent")

    readonly property color fg: Battery.critical ? Colors.fgErrorContainer : (Battery.low ? Colors.fgTertiaryContainer : (Battery.charging ? Colors.primary : Colors.fgSurface))

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.tiny

        MaterialIcon {
            text: Battery.icon
            fill: true
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
            rotation: Battery.icon.startsWith("battery_") && !Battery.icon.includes("charging") && Battery.icon !== "battery_unknown" && Battery.icon !== "battery_alert" ? 90 : 0
        }

        StyledText {
            text: `${Math.round(Battery.percentage * 100)}%`
            font.pointSize: Appearance.fontSize.small
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    StateLayer {
        id: hover
        onClicked: Visibilities.toggle("sidebar")
    }

    Tooltip {
        text: Battery.timeText
        visible: Battery.timeText !== "" && hover.containsMouse
    }
}
