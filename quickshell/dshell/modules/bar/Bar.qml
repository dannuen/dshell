pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.components

// One floating bar per monitor.
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property ShellScreen modelData

        screen: modelData
        visible: Config.bar.showOnAllMonitors || Hypr.focusedScreenName === modelData.name || Quickshell.screens.length === 1
        color: "transparent"
        WlrLayershell.namespace: "dshell-bar"
        WlrLayershell.layer: WlrLayer.Top
        implicitHeight: Config.bar.height
        exclusiveZone: Config.bar.height + (Config.bar.floating ? Config.bar.margin : 0)

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: Config.bar.floating ? Config.bar.margin : 0
            left: Config.bar.floating ? Config.bar.margin : 0
            right: Config.bar.floating ? Config.bar.margin : 0
        }

        Rectangle {
            id: bg
            anchors.fill: parent
            color: Colors.panel
            radius: Config.bar.floating ? Appearance.rounding.normal : 0
            border.width: Config.bar.floating ? 1 : 0
            border.color: Colors.alpha(Colors.outlineVariant, 0.5)

            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim.fast
                }
            }
        }

        // Left: workspaces and window title
        Row {
            id: left
            anchors.left: parent.left
            anchors.leftMargin: Appearance.spacing.small
            anchors.verticalCenter: parent.verticalCenter
            spacing: Appearance.spacing.normal

            Workspaces {
                screen: win.modelData
                anchors.verticalCenter: parent.verticalCenter
            }

            ActiveWindow {
                visible: Config.bar.showWindowTitle
                screen: win.modelData
                anchors.verticalCenter: parent.verticalCenter
                maxWidth: Math.max(100, (win.width - center.width) / 2 - left.x - 220)
            }
        }

        // Center: clock
        Clock {
            id: center
            anchors.centerIn: parent
        }

        // Right: tray, status, battery, power
        Row {
            id: right
            anchors.right: parent.right
            anchors.rightMargin: Appearance.spacing.small
            anchors.verticalCenter: parent.verticalCenter
            spacing: Appearance.spacing.small

            Tray {
                visible: Config.bar.showTray
                bar: win
                anchors.verticalCenter: parent.verticalCenter
            }

            InputMethod {
                visible: Config.bar.showInputMethod && Fcitx.available
                anchors.verticalCenter: parent.verticalCenter
            }

            StatusIcons {
                anchors.verticalCenter: parent.verticalCenter
            }

            BatteryWidget {
                visible: Config.bar.showBattery && Battery.available
                anchors.verticalCenter: parent.verticalCenter
            }

            NotifButton {
                anchors.verticalCenter: parent.verticalCenter
            }

            IconButton {
                icon: "power_settings_new"
                iconColor: Colors.error
                tooltip: "Session"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: Visibilities.toggle("session")
            }
        }
    }
}
