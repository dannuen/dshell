import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components

// Title of the focused window when it is on this monitor.
Item {
    id: root

    required property ShellScreen screen
    property int maxWidth: 400

    readonly property var top: Hypr.activeToplevel
    readonly property bool onThisScreen: top !== null && top.monitor?.name === screen.name
    readonly property string appClass: top?.lastIpcObject?.class ?? ""
    readonly property string title: onThisScreen ? (top?.title ?? "") : ""
    readonly property var entry: appClass ? Apps.byId(appClass) : null

    implicitWidth: title ? Math.min(maxWidth, row.implicitWidth) : 0
    implicitHeight: Config.bar.height
    clip: true

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacing.small

        AppIcon {
            visible: root.title !== ""
            icon: root.entry?.icon ?? root.appClass
            fallback: "web_asset"
            size: 18
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: root.entry?.name ? `${root.entry.name}  ·  ${root.title}` : root.title
            width: Math.min(implicitWidth, root.maxWidth - 26)
            color: Colors.onSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
