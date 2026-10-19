pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.components

// Volume, mic, brightness and input method popup at the bottom of the screen.
Variants {
    id: root

    // "volume", "mic", "brightness", "input"
    property string kind: "volume"
    property bool shown: false

    function show(k: string): void {
        if (Visibilities.sidebar)
            return;
        kind = k;
        shown = true;
        Visibilities.osd = true;
        hideTimer.restart();
    }

    readonly property Timer hideTimer: Timer {
        interval: Config.osd.timeout
        onTriggered: {
            root.shown = false;
            Visibilities.osd = false;
        }
    }

    readonly property Connections audioConn: Connections {
        target: Audio
        function onVolumeChangedByUser(): void {
            if (Config.osd.volume)
                root.show("volume");
        }
        function onMicChangedByUser(): void {
            if (Config.osd.volume)
                root.show("mic");
        }
    }

    readonly property Connections brightConn: Connections {
        target: Brightness
        function onChangedByUser(): void {
            if (Config.osd.brightness)
                root.show("brightness");
        }
    }

    readonly property Connections fcitxConn: Connections {
        target: Fcitx
        function onChanged(): void {
            if (Config.osd.inputMethod)
                root.show("input");
        }
    }

    model: Quickshell.screens

    PanelWindow {
        id: win

        required property ShellScreen modelData
        readonly property bool active: root.shown && Hypr.focusedScreenName === modelData.name
        property bool keep: false

        readonly property string icon: {
            if (root.kind === "mic")
                return Audio.micIcon;
            if (root.kind === "brightness")
                return "brightness_6";
            if (root.kind === "input")
                return "keyboard";
            return Audio.icon;
        }

        readonly property real value: {
            if (root.kind === "mic")
                return Audio.micMuted ? 0 : Audio.micVolume;
            if (root.kind === "brightness")
                return Brightness.brightness;
            return Audio.muted ? 0 : Audio.volume;
        }

        onActiveChanged: {
            if (active)
                keep = true;
            else
                closeTimer.restart();
        }

        Timer {
            id: closeTimer
            interval: Appearance.anim.normal
            onTriggered: if (!win.active)
                win.keep = false
        }

        screen: modelData
        visible: keep
        color: "transparent"
        WlrLayershell.namespace: "dshell-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore

        anchors.bottom: true
        margins.bottom: 48

        implicitWidth: pill.implicitWidth
        implicitHeight: pill.implicitHeight

        PanelFrame {
            id: pill
            padding: Appearance.spacing.normal
            radius: Appearance.rounding.full
            implicitWidth: row.implicitWidth + padding * 2
            implicitHeight: row.implicitHeight + padding * 2
            opacity: win.active ? 1 : 0
            scale: win.active ? 1 : 0.9

            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.anim.normal
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Appearance.anim.normal
                    easing.type: Appearance.anim.emphasized
                }
            }

            Row {
                id: row
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    text: win.icon
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.primary
                    font.pointSize: Appearance.fontSize.iconLarge
                }

                // Input method: show the label only
                StyledText {
                    visible: root.kind === "input"
                    text: Fcitx.vietnamese ? "Tiếng Việt  (VI)" : "English  (EN)"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: Appearance.fontSize.large
                    font.weight: Font.DemiBold
                }

                Item {
                    visible: root.kind !== "input"
                    width: 200
                    height: 12
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.full
                        color: Colors.surfaceContainerHighest
                    }

                    Rectangle {
                        width: Math.max(height, parent.width * Math.max(0, Math.min(1, win.value)))
                        height: parent.height
                        radius: Appearance.rounding.full
                        color: Colors.primary

                        Behavior on width {
                            NumberAnimation {
                                duration: Appearance.anim.fast
                            }
                        }
                    }
                }

                StyledText {
                    visible: root.kind !== "input"
                    text: `${Math.round(win.value * 100)}%`
                    width: 42
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.fgSurfaceVariant
                }
            }
        }
    }
}
