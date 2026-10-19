pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components

// Keybind cheat sheet, Super+slash.
PopupPanel {
    name: "cheatsheet"
    position: "center"
    dimBackground: true

    content: PanelFrame {
        id: frame

        readonly property var groups: [
            {
                title: "Apps",
                binds: [
                    { keys: ["Super", "Return"], desc: "Terminal" },
                    { keys: ["Super", "Space"], desc: "App launcher" },
                    { keys: ["Super", "E"], desc: "Files" },
                    { keys: ["Super", "B"], desc: "Brave" },
                    { keys: ["Super", "O"], desc: "Obsidian" },
                    { keys: ["Super", "M"], desc: "Music (special workspace)" },
                    { keys: ["Super", "U"], desc: "Todo (special workspace)" },
                    { keys: ["Super", "Shift", "S"], desc: "Move window to scratchpad" }
                ]
            },
            {
                title: "Windows",
                binds: [
                    { keys: ["Super", "Q"], desc: "Close window" },
                    { keys: ["Super", "F"], desc: "Fullscreen" },
                    { keys: ["Super", "T"], desc: "Toggle floating" },
                    { keys: ["Super", "Shift", "T"], desc: "Float and center 1000x660" },
                    { keys: ["Super", "Arrows"], desc: "Focus window" },
                    { keys: ["Super", "Shift", "Arrows"], desc: "Move window" },
                    { keys: ["Super", "Ctrl", "Arrows"], desc: "Resize window" },
                    { keys: ["Super", "Mouse"], desc: "Drag to move or resize" }
                ]
            },
            {
                title: "Workspaces",
                binds: [
                    { keys: ["Super", "1..9"], desc: "Go to workspace" },
                    { keys: ["Super", "Shift", "1..9"], desc: "Move window to workspace" },
                    { keys: ["Super", "Tab"], desc: "Overview" },
                    { keys: ["Super", "Scroll"], desc: "Next or previous workspace" }
                ]
            },
            {
                title: "Shell",
                binds: [
                    { keys: ["Super", "V"], desc: "Clipboard history" },
                    { keys: ["Super", "W"], desc: "Wallpaper picker" },
                    { keys: ["Super", "N"], desc: "Notifications" },
                    { keys: ["Super", "A"], desc: "Quick settings" },
                    { keys: ["Super", "D"], desc: "Dashboard" },
                    { keys: ["Super", ","], desc: "Settings" },
                    { keys: ["Super", "/"], desc: "This cheat sheet" }
                ]
            },
            {
                title: "Media and system",
                binds: [
                    { keys: ["Super", "L"], desc: "Lock screen" },
                    { keys: ["Super", "Escape"], desc: "Session menu" },
                    { keys: ["Ctrl", "Space"], desc: "Switch typing EN / VI" },
                    { keys: ["Print"], desc: "Area screenshot" },
                    { keys: ["Shift", "Print"], desc: "Full screen screenshot" },
                    { keys: ["Volume keys"], desc: "Volume with OSD" },
                    { keys: ["Brightness keys"], desc: "Brightness with OSD" },
                    { keys: ["Media keys"], desc: "Play, pause, next, previous" }
                ]
            }
        ]

        readonly property int colWidth: 300

        width: colWidth * 3 + Appearance.spacing.large * 2 + padding * 2
        implicitHeight: body.implicitHeight + padding * 2

        Column {
            id: body
            width: parent.width - frame.padding * 2
            spacing: Appearance.spacing.normal

            Row {
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    text: "keyboard"
                    color: Colors.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: "Keybinds"
                    font.pointSize: Appearance.fontSize.large
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Flow {
                width: parent.width
                spacing: Appearance.spacing.large

                Repeater {
                    model: frame.groups

                    Column {
                        id: group
                        required property var modelData
                        width: frame.colWidth
                        spacing: Appearance.spacing.small

                        StyledText {
                            text: group.modelData.title
                            color: Colors.primary
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: group.modelData.binds

                            Row {
                                id: bind
                                required property var modelData
                                width: group.width
                                spacing: Appearance.spacing.small

                                Row {
                                    id: chips
                                    spacing: 3
                                    anchors.verticalCenter: parent.verticalCenter

                                    Repeater {
                                        model: bind.modelData.keys

                                        Rectangle {
                                            required property string modelData
                                            width: chipText.implicitWidth + 12
                                            height: 24
                                            radius: Appearance.rounding.small
                                            color: Colors.surfaceContainerHighest
                                            border.width: 1
                                            border.color: Colors.alpha(Colors.outline, 0.4)

                                            StyledText {
                                                id: chipText
                                                anchors.centerIn: parent
                                                text: parent.modelData
                                                font.pointSize: Appearance.fontSize.small
                                                font.family: Appearance.monoFont
                                            }
                                        }
                                    }
                                }

                                StyledText {
                                    width: parent.width - chips.width - parent.spacing
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: bind.modelData.desc
                                    color: Colors.fgSurfaceVariant
                                    font.pointSize: Appearance.fontSize.small
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
