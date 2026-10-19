import QtQuick
import qs.config
import qs.services
import qs.components

IconButton {
    id: root

    icon: Notifs.dnd ? "notifications_off" : (Notifs.unread > 0 ? "notifications_unread" : "notifications")
    fill: Notifs.unread > 0
    active: Visibilities.notifHistory
    tooltip: Notifs.dnd ? "Do not disturb" : `${Notifs.list.length} notifications`
    onClicked: Visibilities.toggle("notifHistory")
    onRightClicked: Notifs.toggleDnd()

    Rectangle {
        visible: Notifs.unread > 0 && !Notifs.dnd
        width: 8
        height: 8
        radius: 4
        color: Colors.error
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
    }
}
