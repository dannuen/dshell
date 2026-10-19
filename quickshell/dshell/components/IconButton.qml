import QtQuick
import qs.config
import qs.services

// Round icon button.
StyledRect {
    id: root

    property alias icon: iconItem.text
    property alias fill: iconItem.fill
    property alias iconSize: iconItem.font.pointSize
    property color iconColor: Colors.fgSurface
    property bool active: false
    property bool disabled: false
    property string tooltip: ""
    property int padding: Appearance.spacing.small

    signal clicked(var mouse)
    signal rightClicked(var mouse)
    signal wheel(var wheel)

    implicitWidth: iconItem.implicitWidth + padding * 2 + 4
    implicitHeight: iconItem.implicitHeight + padding * 2
    radius: Appearance.rounding.full
    color: active ? Colors.primaryContainer : "transparent"
    opacity: disabled ? 0.4 : 1

    MaterialIcon {
        id: iconItem
        anchors.centerIn: parent
        color: root.active ? Colors.fgPrimaryContainer : root.iconColor
    }

    StateLayer {
        id: stateLayer
        disabled: root.disabled
        color: root.active ? Colors.fgPrimaryContainer : Colors.fgSurface
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                root.rightClicked(mouse);
            else
                root.clicked(mouse);
        }
        onWheel: wheel => root.wheel(wheel)
    }

    Tooltip {
        text: root.tooltip
        visible: root.tooltip !== "" && stateLayer.containsMouse
    }
}
