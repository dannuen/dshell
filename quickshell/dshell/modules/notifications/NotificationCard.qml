pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config
import qs.services
import qs.components
import qs.utils

// One notification. Used by the popups and by the history list.
PanelFrame {
    id: root

    required property var notif
    property bool inHistory: false

    signal closeRequested

    readonly property bool critical: notif.urgency === NotificationUrgency.Critical

    width: 380
    padding: Appearance.spacing.normal
    implicitHeight: column.implicitHeight + padding * 2
    color: inHistory ? Colors.surfaceContainer : Colors.panel

    Rectangle {
        visible: root.critical
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 6
        width: 4
        radius: 2
        color: Colors.error
        z: 2
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const def = root.notif.actions.find(a => a.identifier === "default");
            if (def)
                root.notif.invoke(def.identifier);
            root.closeRequested();
        }
    }

    Column {
        id: column
        width: parent.width
        spacing: Appearance.spacing.small

        Row {
            width: parent.width
            spacing: Appearance.spacing.normal

            AppIcon {
                anchors.verticalCenter: parent.verticalCenter
                icon: root.notif.image !== "" ? root.notif.image : root.notif.appIcon
                fallback: "notifications"
                size: 40
            }

            Column {
                width: parent.width - 40 - closeBtn.width - parent.spacing * 2
                spacing: Appearance.spacing.tiny
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    width: parent.width
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: root.notif.appName
                        color: Colors.onSurfaceVariant
                        font.pointSize: Appearance.fontSize.small
                        width: Math.min(implicitWidth, parent.width - timeText.width - parent.spacing)
                    }

                    StyledText {
                        id: timeText
                        text: Time.ago(root.notif.time)
                        color: Colors.outline
                        font.pointSize: Appearance.fontSize.small
                    }
                }

                StyledText {
                    width: parent.width
                    text: root.notif.summary
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                }

                Text {
                    width: parent.width
                    visible: root.notif.body !== ""
                    text: root.notif.body
                    color: Colors.onSurfaceVariant
                    font.family: Appearance.font
                    font.pointSize: Appearance.fontSize.normal
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    linkColor: Colors.primary
                    onLinkActivated: link => Quickshell.execDetached(["xdg-open", link])
                }
            }

            IconButton {
                id: closeBtn
                anchors.verticalCenter: parent.verticalCenter
                icon: "close"
                iconSize: Appearance.fontSize.normal
                onClicked: root.closeRequested()
            }
        }

        Flow {
            width: parent.width
            spacing: Appearance.spacing.small
            visible: root.notif.actions.filter(a => a.identifier !== "default").length > 0

            Repeater {
                model: root.notif.actions.filter(a => a.identifier !== "default")

                TextButton {
                    required property var modelData
                    text: modelData.text
                    implicitHeight: 32
                    onClicked: root.notif.invoke(modelData.identifier)
                }
            }
        }
    }
}
