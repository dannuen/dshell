import QtQuick
import qs.config
import qs.services
import qs.components

// Time and date. Click opens the dashboard.
StyledRect {
    id: root

    implicitWidth: row.implicitWidth + Appearance.spacing.large * 2
    implicitHeight: Config.bar.height - Appearance.spacing.normal
    radius: Appearance.rounding.full
    color: Visibilities.dashboard ? Colors.primaryContainer : "transparent"

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.normal

        StyledText {
            text: Time.format(Config.bar.clockFormat)
            font.bold: true
            color: Visibilities.dashboard ? Colors.onPrimaryContainer : Colors.onSurface
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: Time.format(Config.bar.dateFormat)
            color: Visibilities.dashboard ? Colors.onPrimaryContainer : Colors.onSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    StateLayer {
        onClicked: Visibilities.toggle("dashboard")
    }
}
