import QtQuick
import qs.config
import qs.services

// Simple tooltip drawn inside the same window below the parent item.
Item {
    id: root

    property string text: ""
    property int delay: 500

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.bottom
    anchors.topMargin: Appearance.spacing.small
    width: label.implicitWidth + Appearance.spacing.normal * 2
    height: label.implicitHeight + Appearance.spacing.small * 2
    opacity: 0
    z: 1000

    onVisibleChanged: {
        if (visible)
            showTimer.restart();
        else {
            showTimer.stop();
            opacity = 0;
        }
    }

    Timer {
        id: showTimer
        interval: root.delay
        onTriggered: root.opacity = 1
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.anim.fast
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.small
        color: Colors.inverseSurface
    }

    StyledText {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: Colors.inverseOnSurface
        font.pointSize: Appearance.fontSize.small
    }
}
