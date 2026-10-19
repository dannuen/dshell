import QtQuick
import qs.config
import qs.services

// Pill button with optional icon and label.
StyledRect {
    id: root

    property string text: ""
    property string icon: ""
    property bool primary: false
    property bool active: false
    property bool disabled: false
    property color textColor: primary ? Colors.fgPrimary : (active ? Colors.fgPrimaryContainer : Colors.fgSurface)

    signal clicked

    implicitWidth: row.implicitWidth + Appearance.spacing.large * 2
    implicitHeight: row.implicitHeight + Appearance.spacing.normal * 2
    radius: Appearance.rounding.full
    color: primary ? Colors.primary : (active ? Colors.primaryContainer : Colors.surfaceContainerHigh)
    opacity: disabled ? 0.4 : 1

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        MaterialIcon {
            visible: root.icon !== ""
            text: root.icon
            color: root.textColor
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            visible: root.text !== ""
            text: root.text
            color: root.textColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    StateLayer {
        disabled: root.disabled
        color: root.textColor
        onClicked: root.clicked()
    }
}
