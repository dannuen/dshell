import QtQuick
import qs.config
import qs.services
import qs.components

// Rounded tile for the quick settings grid.
StyledRect {
    id: root

    property string icon: ""
    property string label: ""
    property string subLabel: ""
    property bool active: false
    property bool expandable: false
    property bool expanded: false

    signal clicked
    signal expandClicked

    implicitHeight: 64
    radius: Appearance.rounding.normal
    color: active ? Colors.primaryContainer : Colors.surfaceContainerHigh

    readonly property color fg: active ? Colors.onPrimaryContainer : Colors.onSurface
    readonly property color fgDim: active ? Colors.onPrimaryContainer : Colors.onSurfaceVariant

    StateLayer {
        color: root.fg
        onClicked: root.clicked()
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Appearance.spacing.normal
        anchors.rightMargin: Appearance.spacing.small
        spacing: Appearance.spacing.normal

        MaterialIcon {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.fg
            fill: root.active
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 30 - (root.expandable ? chevron.width + parent.spacing : 0) - parent.spacing
            spacing: 0

            StyledText {
                width: parent.width
                text: root.label
                color: root.fg
                font.weight: Font.DemiBold
            }

            StyledText {
                width: parent.width
                visible: root.subLabel !== ""
                text: root.subLabel
                color: root.fgDim
                font.pointSize: Appearance.fontSize.small
            }
        }

        IconButton {
            id: chevron
            visible: root.expandable
            anchors.verticalCenter: parent.verticalCenter
            icon: root.expanded ? "expand_less" : "expand_more"
            iconColor: root.fg
            onClicked: root.expandClicked()
        }
    }
}
