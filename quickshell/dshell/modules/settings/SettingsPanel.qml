pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components

// Settings panel, Super+comma. Writes ~/.config/dshell/settings.json.
PopupPanel {
    name: "settings"
    position: "center"
    dimBackground: true

    content: PanelFrame {
        id: frame

        property int current: 0

        readonly property var sections: [
            {
                id: "general",
                title: "General",
                icon: "tune",
                fields: [
                    { key: "terminal", label: "Terminal", type: "string" },
                    { key: "browser", label: "Browser", type: "string" },
                    { key: "fileManager", label: "File manager", type: "string" },
                    { key: "editor", label: "Editor", type: "string" },
                    { key: "laptop", label: "This is a laptop", type: "bool" }
                ]
            },
            {
                id: "appearance",
                title: "Appearance",
                icon: "palette",
                fields: [
                    { key: "font", label: "Font", type: "string" },
                    { key: "iconFont", label: "Icon font", type: "string" },
                    { key: "fontSize", label: "Font size", type: "int", min: 8, max: 24 },
                    { key: "rounding", label: "Corner rounding", type: "int", min: 0, max: 40 },
                    { key: "padding", label: "Padding", type: "int", min: 2, max: 24 },
                    { key: "animationSpeed", label: "Animation speed", type: "real", min: 0, max: 3, step: 0.1 },
                    { key: "panelOpacity", label: "Panel opacity", type: "real", min: 0.3, max: 1, step: 0.05 },
                    { key: "blur", label: "Blur behind panels", type: "bool" }
                ]
            },
            {
                id: "theme",
                title: "Theme",
                icon: "dark_mode",
                fields: [
                    { key: "mode", label: "Mode", type: "choice", choices: ["dark", "light"] },
                    { key: "scheme", label: "Color scheme", type: "choice", choices: ["scheme-tonal-spot", "scheme-vibrant", "scheme-expressive", "scheme-fruit-salad", "scheme-rainbow", "scheme-neutral", "scheme-monochrome", "scheme-content", "scheme-fidelity"] }
                ]
            },
            {
                id: "bar",
                title: "Bar",
                icon: "web_asset",
                fields: [
                    { key: "height", label: "Height", type: "int", min: 24, max: 64 },
                    { key: "margin", label: "Margin", type: "int", min: 0, max: 32 },
                    { key: "floating", label: "Floating bar", type: "bool" },
                    { key: "showOnAllMonitors", label: "Show on all monitors", type: "bool" },
                    { key: "showWindowTitle", label: "Show window title", type: "bool" },
                    { key: "showInputMethod", label: "Show input method", type: "bool" },
                    { key: "showBattery", label: "Show battery", type: "bool" },
                    { key: "showTray", label: "Show system tray", type: "bool" },
                    { key: "workspaceCount", label: "Workspaces shown", type: "int", min: 1, max: 10 },
                    { key: "workspaceNumbers", label: "Workspace numbers", type: "bool" },
                    { key: "clockFormat", label: "Clock format", type: "string" },
                    { key: "dateFormat", label: "Date format", type: "string" }
                ]
            },
            {
                id: "launcher",
                title: "Launcher",
                icon: "apps",
                fields: [
                    { key: "maxResults", label: "Results shown", type: "int", min: 3, max: 20 },
                    { key: "width", label: "Width", type: "int", min: 400, max: 1200, step: 20 },
                    { key: "sortByUsage", label: "Sort by usage", type: "bool" },
                    { key: "calcPrefix", label: "Calculator prefix", type: "string" },
                    { key: "shellPrefix", label: "Shell command prefix", type: "string" },
                    { key: "emojiPrefix", label: "Emoji prefix", type: "string" },
                    { key: "windowPrefix", label: "Windows prefix", type: "string" },
                    { key: "clipPrefix", label: "Clipboard prefix", type: "string" },
                    { key: "wallPrefix", label: "Wallpaper prefix", type: "string" }
                ]
            },
            {
                id: "notifications",
                title: "Notifications",
                icon: "notifications",
                fields: [
                    { key: "timeout", label: "Popup timeout (ms)", type: "int", min: 0, max: 60000, step: 500 },
                    { key: "criticalTimeout", label: "Critical timeout (ms, 0 = stay)", type: "int", min: 0, max: 60000, step: 500 },
                    { key: "maxPopups", label: "Max popups", type: "int", min: 1, max: 10 },
                    { key: "historySize", label: "History size", type: "int", min: 10, max: 500, step: 10 },
                    { key: "dnd", label: "Do not disturb", type: "bool" }
                ]
            },
            {
                id: "osd",
                title: "OSD",
                icon: "volume_up",
                fields: [
                    { key: "timeout", label: "Timeout (ms)", type: "int", min: 300, max: 5000, step: 100 },
                    { key: "volume", label: "Show for volume", type: "bool" },
                    { key: "brightness", label: "Show for brightness", type: "bool" },
                    { key: "inputMethod", label: "Show for input method", type: "bool" }
                ]
            },
            {
                id: "lock",
                title: "Lock",
                icon: "lock",
                fields: [
                    { key: "blur", label: "Blur wallpaper", type: "bool" },
                    { key: "clockFormat", label: "Clock format", type: "string" },
                    { key: "dateFormat", label: "Date format", type: "string" }
                ]
            },
            {
                id: "sidebar",
                title: "Sidebar",
                icon: "side_navigation",
                fields: [
                    { key: "width", label: "Width", type: "int", min: 300, max: 700, step: 10 },
                    { key: "nightTemperature", label: "Night light temperature (K)", type: "int", min: 1500, max: 6500, step: 100 }
                ]
            },
            {
                id: "dashboard",
                title: "Dashboard",
                icon: "dashboard",
                fields: [
                    { key: "width", label: "Width", type: "int", min: 500, max: 1200, step: 20 },
                    { key: "showCalendar", label: "Show calendar", type: "bool" },
                    { key: "showMedia", label: "Show media player", type: "bool" },
                    { key: "showWeather", label: "Show weather", type: "bool" },
                    { key: "showStats", label: "Show system stats", type: "bool" }
                ]
            },
            {
                id: "wallpaper",
                title: "Wallpaper",
                icon: "wallpaper",
                fields: [
                    { key: "dir", label: "Wallpaper folder", type: "string" },
                    { key: "current", label: "Current wallpaper", type: "string" },
                    { key: "transition", label: "Transition", type: "choice", choices: ["fade", "wipe", "grow", "any"] }
                ]
            },
            {
                id: "weather",
                title: "Weather",
                icon: "cloud",
                fields: [
                    { key: "location", label: "Location (empty = auto)", type: "string" },
                    { key: "celsius", label: "Use Celsius", type: "bool" },
                    { key: "refreshMinutes", label: "Refresh every (min)", type: "int", min: 5, max: 240, step: 5 }
                ]
            },
            {
                id: "hooks",
                title: "Hooks",
                icon: "terminal",
                fields: [
                    { key: "wallpaperChanged", label: "On wallpaper changed", type: "string" },
                    { key: "themeChanged", label: "On theme changed", type: "string" },
                    { key: "locked", label: "On lock", type: "string" },
                    { key: "unlocked", label: "On unlock", type: "string" }
                ]
            }
        ]

        readonly property var section: sections[current]

        width: 760 + padding * 2
        implicitHeight: 560 + padding * 2

        // Section list
        Column {
            id: nav
            width: 200
            spacing: Appearance.spacing.tiny

            Repeater {
                model: frame.sections

                StyledRect {
                    id: navItem
                    required property var modelData
                    required property int index
                    readonly property bool selected: frame.current === index

                    width: nav.width
                    implicitHeight: 36
                    radius: Appearance.rounding.full
                    color: selected ? Colors.secondaryContainer : "transparent"

                    StateLayer {
                        onClicked: frame.current = navItem.index
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.spacing.normal
                        spacing: Appearance.spacing.normal

                        MaterialIcon {
                            text: navItem.modelData.icon
                            anchors.verticalCenter: parent.verticalCenter
                            color: navItem.selected ? Colors.onSecondaryContainer : Colors.onSurfaceVariant
                            font.pointSize: Appearance.fontSize.normal + 2
                        }

                        StyledText {
                            text: navItem.modelData.title
                            anchors.verticalCenter: parent.verticalCenter
                            color: navItem.selected ? Colors.onSecondaryContainer : Colors.onSurface
                            font.weight: navItem.selected ? Font.DemiBold : Font.Normal
                        }
                    }
                }
            }
        }

        // Fields
        Item {
            x: nav.width + Appearance.spacing.large
            width: 760 - x
            height: 560

            StyledText {
                id: title
                text: frame.section.title
                font.pointSize: Appearance.fontSize.large
                font.weight: Font.DemiBold
            }

            Flickable {
                anchors.top: title.bottom
                anchors.topMargin: Appearance.spacing.normal
                anchors.bottom: footer.top
                anchors.bottomMargin: Appearance.spacing.normal
                width: parent.width
                contentHeight: fields.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: fields
                    width: parent.width
                    spacing: Appearance.spacing.small

                    Repeater {
                        model: frame.section.fields

                        SettingField {
                            required property var modelData
                            width: fields.width
                            section: frame.section.id
                            field: modelData
                        }
                    }
                }
            }

            Row {
                id: footer
                anchors.bottom: parent.bottom
                spacing: Appearance.spacing.small

                TextButton {
                    text: "Open settings.json"
                    icon: "edit_note"
                    onClicked: Quickshell.execDetached(["xdg-open", Config.settingsPath])
                }

                TextButton {
                    text: "Reload shell"
                    icon: "refresh"
                    onClicked: Quickshell.reload(true)
                }
            }
        }
    }
}
