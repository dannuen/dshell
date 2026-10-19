import QtQuick
import qs.config
import qs.services

// Material style switch.
Item {
    id: root

    property bool checked: false
    signal toggled(bool checked)

    implicitWidth: 48
    implicitHeight: 28

    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.full
        color: root.checked ? Colors.primary : Colors.surfaceContainerHighest
        border.width: root.checked ? 0 : 2
        border.color: Colors.outline

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.fast
            }
        }

        Rectangle {
            width: root.checked ? 22 : 16
            height: width
            radius: Appearance.rounding.full
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 3 : 6
            color: root.checked ? Colors.onPrimary : Colors.outline

            Behavior on x {
                NumberAnimation {
                    duration: Appearance.anim.fast
                    easing.type: Appearance.anim.curve
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: Appearance.anim.fast
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
