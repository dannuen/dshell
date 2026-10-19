import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.services

// Icon from the icon theme by name, falls back to a Material icon.
Item {
    id: root

    property string icon: ""
    property string fallback: "apps"
    property int size: 32

    readonly property string path: Quickshell.iconPath(icon, true)

    implicitWidth: size
    implicitHeight: size

    IconImage {
        anchors.fill: parent
        visible: root.path !== ""
        source: root.path
        asynchronous: true
    }

    MaterialIcon {
        anchors.centerIn: parent
        visible: root.path === ""
        text: root.fallback
        font.pointSize: root.size * 0.6
        color: Colors.fgSurfaceVariant
    }
}
