pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components

// Notification history, Super+N.
PopupPanel {
    name: "notifHistory"
    position: "topRight"

    onOpened: Notifs.markRead()

    content: PanelFrame {
        id: frame

        width: 400 + padding * 2
        implicitHeight: col.implicitHeight + padding * 2

        Column {
            id: col
            width: 400
            spacing: Appearance.spacing.normal

            Row {
                width: parent.width
                spacing: Appearance.spacing.normal

                StyledText {
                    text: "Notifications"
                    font.pointSize: Appearance.fontSize.large
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - dndRow.width - clearBtn.width - parent.spacing * 2
                }

                Row {
                    id: dndRow
                    spacing: Appearance.spacing.small
                    anchors.verticalCenter: parent.verticalCenter

                    MaterialIcon {
                        text: "do_not_disturb_on"
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.fgSurfaceVariant
                    }

                    StyledSwitch {
                        anchors.verticalCenter: parent.verticalCenter
                        checked: Notifs.dnd
                        onToggled: Notifs.toggleDnd()
                    }
                }

                TextButton {
                    id: clearBtn
                    text: "Clear all"
                    icon: "delete_sweep"
                    implicitHeight: 36
                    disabled: Notifs.list.length === 0
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: Notifs.clear()
                }
            }

            StyledText {
                visible: Notifs.list.length === 0
                width: parent.width
                height: 80
                text: "No notifications"
                horizontalAlignment: Text.AlignHCenter
                color: Colors.fgSurfaceVariant
            }

            ListView {
                id: list
                visible: Notifs.list.length > 0
                width: parent.width
                height: Math.min(600, contentHeight)
                clip: true
                spacing: Appearance.spacing.small
                model: Notifs.list
                boundsBehavior: Flickable.StopAtBounds

                delegate: NotificationCard {
                    required property var modelData
                    width: list.width
                    notif: modelData
                    inHistory: true
                    onCloseRequested: Notifs.dismiss(modelData.id)
                }
            }
        }
    }
}
