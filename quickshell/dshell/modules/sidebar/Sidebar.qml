pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components
import qs.utils

// Quick settings sidebar, Super+A or click on the bar status icons.
PopupPanel {
    id: root
    name: "sidebar"
    position: "topRight"

    content: PanelFrame {
        id: frame

        // "", "wifi", "bluetooth", "mixer"
        property string expanded: ""

        readonly property int innerWidth: Config.sidebar.width
        readonly property int maxHeight: (Quickshell.screens[0]?.height ?? 1080) * 0.85 - Config.bar.height - Config.bar.margin * 3

        width: innerWidth + padding * 2
        implicitHeight: Math.min(maxHeight, flick.contentHeight + padding * 2)

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: col.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: col
                width: flick.width
                spacing: Appearance.spacing.normal

                // Header
                Row {
                    width: parent.width
                    spacing: Appearance.spacing.small

                    Row {
                        visible: Battery.available
                        spacing: Appearance.spacing.small
                        anchors.verticalCenter: parent.verticalCenter

                        MaterialIcon {
                            text: Battery.icon
                            color: Battery.low ? Colors.error : Colors.onSurface
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: Format.percent(Battery.percentage)
                                font.weight: Font.DemiBold
                            }

                            StyledText {
                                visible: Battery.timeText !== ""
                                text: Battery.timeText
                                color: Colors.onSurfaceVariant
                                font.pointSize: Appearance.fontSize.small
                            }
                        }
                    }

                    StyledText {
                        visible: !Battery.available
                        text: "Quick settings"
                        font.pointSize: Appearance.fontSize.large
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: parent.width - (Battery.available ? 110 : 140) - 44 * 2 - parent.spacing * 3
                        height: 1
                    }

                    IconButton {
                        icon: "settings"
                        tooltip: "Settings"
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: Visibilities.open("settings")
                    }

                    IconButton {
                        icon: "power_settings_new"
                        tooltip: "Session"
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: Visibilities.open("session")
                    }
                }

                // Toggles
                Grid {
                    id: grid
                    width: parent.width
                    columns: 2
                    columnSpacing: Appearance.spacing.small
                    rowSpacing: Appearance.spacing.small

                    readonly property int tileWidth: (width - columnSpacing) / 2

                    QuickToggle {
                        width: grid.tileWidth
                        icon: Network.icon
                        label: "Wi-Fi"
                        subLabel: Network.label
                        active: Network.wifiEnabled
                        expandable: true
                        expanded: frame.expanded === "wifi"
                        onClicked: Network.toggleWifi()
                        onExpandClicked: frame.expanded = frame.expanded === "wifi" ? "" : "wifi"
                    }

                    QuickToggle {
                        width: grid.tileWidth
                        icon: Bluetooth.icon
                        label: "Bluetooth"
                        subLabel: Bluetooth.label
                        active: Bluetooth.enabled
                        expandable: Bluetooth.available
                        expanded: frame.expanded === "bluetooth"
                        onClicked: Bluetooth.toggle()
                        onExpandClicked: frame.expanded = frame.expanded === "bluetooth" ? "" : "bluetooth"
                    }

                    QuickToggle {
                        width: grid.tileWidth
                        icon: "nightlight"
                        label: "Night light"
                        subLabel: Toggles.nightLight ? "On" : "Off"
                        active: Toggles.nightLight
                        onClicked: Toggles.toggleNightLight()
                    }

                    QuickToggle {
                        width: grid.tileWidth
                        icon: "do_not_disturb_on"
                        label: "Do not disturb"
                        subLabel: Notifs.dnd ? "On" : "Off"
                        active: Notifs.dnd
                        onClicked: Notifs.toggleDnd()
                    }

                    QuickToggle {
                        width: grid.tileWidth
                        icon: "coffee"
                        label: "Caffeine"
                        subLabel: Toggles.caffeine ? "Screen stays on" : "Off"
                        active: Toggles.caffeine
                        onClicked: Toggles.toggleCaffeine()
                    }

                    QuickToggle {
                        width: grid.tileWidth
                        icon: Toggles.powerIcon
                        label: "Power profile"
                        subLabel: Format.capitalize(Toggles.powerProfile.replace("-", " "))
                        active: Toggles.powerProfile === "performance"
                        onClicked: Toggles.cyclePowerProfile()
                    }

                    QuickToggle {
                        width: grid.tileWidth
                        icon: Colors.light ? "light_mode" : "dark_mode"
                        label: "Dark mode"
                        subLabel: Colors.light ? "Light" : "Dark"
                        active: !Colors.light
                        onClicked: Wallpapers.toggleMode()
                    }

                    QuickToggle {
                        width: grid.tileWidth
                        icon: "keyboard"
                        label: "Input method"
                        subLabel: Fcitx.vietnamese ? "Tiếng Việt" : "English"
                        active: Fcitx.vietnamese
                        onClicked: Fcitx.toggle()
                    }
                }

                // Expanded lists
                Loader {
                    width: parent.width
                    active: frame.expanded === "wifi"
                    visible: active
                    sourceComponent: WifiList {
                        width: col.width
                    }
                }

                Loader {
                    width: parent.width
                    active: frame.expanded === "bluetooth"
                    visible: active
                    sourceComponent: BluetoothList {
                        width: col.width
                    }
                }

                Separator {
                    width: parent.width
                }

                // Sliders
                StyledSlider {
                    width: parent.width
                    icon: Audio.icon
                    value: Audio.volume
                    showPercent: true
                    onMoved: v => Audio.setVolume(v)
                }

                StyledSlider {
                    width: parent.width
                    icon: Audio.micIcon
                    value: Audio.micVolume
                    accent: Audio.micMuted ? Colors.outline : Colors.primary
                    showPercent: true
                    onMoved: v => Audio.setMicVolume(v)
                }

                StyledSlider {
                    visible: Brightness.available
                    width: parent.width
                    icon: "brightness_6"
                    value: Brightness.brightness
                    showPercent: true
                    onMoved: v => Brightness.setBrightness(v)
                }

                // Mixer
                StyledRect {
                    width: parent.width
                    implicitHeight: 40
                    radius: Appearance.rounding.small
                    color: "transparent"

                    StateLayer {
                        onClicked: frame.expanded = frame.expanded === "mixer" ? "" : "mixer"
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.spacing.small
                        spacing: Appearance.spacing.normal

                        MaterialIcon {
                            text: "tune"
                            anchors.verticalCenter: parent.verticalCenter
                            color: Colors.onSurfaceVariant
                        }

                        StyledText {
                            text: "Apps and output"
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 30 * 2 - parent.spacing * 2
                        }

                        MaterialIcon {
                            text: frame.expanded === "mixer" ? "expand_less" : "expand_more"
                            anchors.verticalCenter: parent.verticalCenter
                            color: Colors.onSurfaceVariant
                        }
                    }
                }

                Loader {
                    width: parent.width
                    active: frame.expanded === "mixer"
                    visible: active
                    sourceComponent: Mixer {
                        width: col.width
                    }
                }
            }
        }
    }
}
