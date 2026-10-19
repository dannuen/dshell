pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.components

// Notification popups in the top right corner of the focused monitor.
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property ShellScreen modelData
        readonly property var popups: Notifs.popups.slice(0, Config.notifications.maxPopups)

        screen: modelData
        visible: popups.length > 0 && Hypr.focusedScreenName === modelData.name
        color: "transparent"
        WlrLayershell.namespace: "dshell-notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            right: true
        }

        margins {
            top: Config.bar.height + Config.bar.margin * 2
            right: Config.bar.margin
        }

        implicitWidth: 380 + Appearance.spacing.normal
        implicitHeight: Math.max(1, column.implicitHeight + Appearance.spacing.normal)

        Column {
            id: column
            anchors.top: parent.top
            anchors.right: parent.right
            spacing: Appearance.spacing.small

            move: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: Appearance.anim.normal
                    easing.type: Appearance.anim.curve
                }
            }

            add: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Appearance.anim.normal
                }
                NumberAnimation {
                    property: "x"
                    from: 60
                    to: 0
                    duration: Appearance.anim.normal
                    easing.type: Appearance.anim.emphasized
                }
            }

            Repeater {
                model: win.popups

                NotificationCard {
                    required property var modelData
                    notif: modelData
                    onCloseRequested: Notifs.hidePopup(modelData.id)
                }
            }
        }
    }
}
