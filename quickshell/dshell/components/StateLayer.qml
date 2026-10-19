import QtQuick
import qs.config
import qs.services

// Hover and press overlay plus a MouseArea, drop into any rectangle.
MouseArea {
    id: root

    property color color: Colors.onSurface
    property bool disabled: false
    property real radius: parent?.radius ?? 0

    anchors.fill: parent
    hoverEnabled: true
    cursorShape: disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
    enabled: !disabled

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.color
        opacity: root.pressed ? 0.16 : (root.containsMouse ? 0.08 : 0)

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.anim.fast
            }
        }
    }
}
