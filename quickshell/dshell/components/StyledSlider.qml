import QtQuick
import qs.config
import qs.services

// Horizontal slider with an optional icon. Emits `moved(value)` while dragging.
Item {
    id: root

    property real value: 0
    property string icon: ""
    property color accent: Colors.primary
    property bool showPercent: false
    property int trackHeight: 28

    signal moved(real value)

    implicitHeight: trackHeight
    implicitWidth: 200

    Row {
        anchors.fill: parent
        spacing: Appearance.spacing.normal

        MaterialIcon {
            id: iconItem
            visible: root.icon !== ""
            text: root.icon
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.onSurfaceVariant
        }

        Item {
            id: track
            width: parent.width - (iconItem.visible ? iconItem.width + parent.spacing : 0) - (pct.visible ? pct.width + parent.spacing : 0)
            height: parent.height

            Rectangle {
                anchors.fill: parent
                radius: Appearance.rounding.full
                color: Colors.surfaceContainerHighest
            }

            Rectangle {
                width: Math.max(height, parent.width * Math.max(0, Math.min(1, root.value)))
                height: parent.height
                radius: Appearance.rounding.full
                color: root.accent

                Behavior on width {
                    enabled: !mouse.pressed
                    NumberAnimation {
                        duration: Appearance.anim.fast
                    }
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                preventStealing: true

                function update(x: real): void {
                    const v = Math.max(0, Math.min(1, x / width));
                    root.moved(v);
                }

                onPressed: mouse => update(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed)
                        update(mouse.x);
                }
                onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
            }
        }

        StyledText {
            id: pct
            visible: root.showPercent
            text: `${Math.round(root.value * 100)}%`
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.onSurfaceVariant
            font.pointSize: Appearance.fontSize.small
            width: 36
            horizontalAlignment: Text.AlignRight
        }
    }
}
