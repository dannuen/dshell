pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components

// Lock, logout, suspend, reboot, shutdown. Super+Escape.
PopupPanel {
    id: root

    name: "session"
    position: "center"
    dimBackground: true

    content: Component {
        PanelFrame {
            id: frame

            property int selected: 0

            readonly property list<var> actions: [
                {
                    icon: "lock",
                    label: "Lock",
                    key: Qt.Key_L,
                    run: () => Visibilities.lockRequested()
                },
                {
                    icon: "logout",
                    label: "Log out",
                    key: Qt.Key_E,
                    run: () => Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
                },
                {
                    icon: "bedtime",
                    label: "Suspend",
                    key: Qt.Key_U,
                    run: () => Quickshell.execDetached(["systemctl", "suspend"])
                },
                {
                    icon: "restart_alt",
                    label: "Reboot",
                    key: Qt.Key_R,
                    run: () => Quickshell.execDetached(["systemctl", "reboot"])
                },
                {
                    icon: "power_settings_new",
                    label: "Shut down",
                    key: Qt.Key_S,
                    run: () => Quickshell.execDetached(["systemctl", "poweroff"])
                }
            ]

            function activate(i: int): void {
                const a = actions[i];
                if (!a)
                    return;
                Visibilities.session = false;
                a.run();
            }

            padding: Appearance.spacing.huge
            focus: true
            Component.onCompleted: forceActiveFocus()

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                    selected = (selected + actions.length - 1) % actions.length;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                    selected = (selected + 1) % actions.length;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    activate(selected);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Escape) {
                    Visibilities.session = false;
                    event.accepted = true;
                } else {
                    const i = actions.findIndex(a => a.key === event.key);
                    if (i >= 0) {
                        activate(i);
                        event.accepted = true;
                    }
                }
            }

            Row {
                spacing: Appearance.spacing.large

                Repeater {
                    model: frame.actions

                    delegate: Column {
                        id: item
                        required property var modelData
                        required property int index
                        readonly property bool selected: index === frame.selected

                        spacing: Appearance.spacing.normal

                        StyledRect {
                            id: button
                            width: 96
                            height: 96
                            radius: Appearance.rounding.full
                            color: item.selected ? Colors.primary : Colors.surfaceContainerHigh
                            anchors.horizontalCenter: parent.horizontalCenter

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: item.modelData.icon
                                font.pointSize: Appearance.fontSize.iconLarge + 10
                                color: item.selected ? Colors.fgPrimary : Colors.fgSurface
                            }

                            StateLayer {
                                color: item.selected ? Colors.fgPrimary : Colors.fgSurface
                                onContainsMouseChanged: if (containsMouse)
                                    frame.selected = item.index
                                onClicked: frame.activate(item.index)
                            }
                        }

                        StyledText {
                            text: item.modelData.label
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: item.selected ? Colors.primary : Colors.fgSurfaceVariant
                        }
                    }
                }
            }
        }
    }
}
