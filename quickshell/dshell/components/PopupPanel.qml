import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.services

// A pop out panel shown on the focused monitor. Opens when
// Visibilities[name] is true, closes on Escape or on a click outside.
// Place the panel content as the `content` component.
Variants {
    id: root

    required property string name
    property Component content: null
    // where the panel sits: "top", "topLeft", "topRight", "center", "left", "right"
    property string position: "top"
    property int offset: Config.bar.margin
    property bool takesKeyboard: true
    property bool dimBackground: false

    signal opened
    signal closed

    model: Quickshell.screens

    PanelWindow {
        id: win

        required property ShellScreen modelData
        readonly property bool shouldShow: Visibilities[root.name] && Hypr.focusedScreenName === modelData.name
        property bool shown: false

        screen: modelData
        visible: shown || Visibilities[root.name] && Hypr.focusedScreenName === modelData.name
        color: "transparent"
        WlrLayershell.namespace: `dshell-${root.name}`
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: shouldShow && root.takesKeyboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        onShouldShowChanged: {
            if (shouldShow) {
                shown = true;
                root.opened();
            } else {
                hideTimer.restart();
                root.closed();
            }
        }

        Timer {
            id: hideTimer
            interval: Appearance.anim.normal
            onTriggered: if (!win.shouldShow)
                win.shown = false
        }

        HyprlandFocusGrab {
            active: win.shouldShow
            windows: [win]
            onCleared: Visibilities[root.name] = false
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.alpha("black", root.dimBackground ? 0.3 : 0)
            opacity: win.shouldShow ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.anim.normal
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Visibilities[root.name] = false
        }

        Item {
            id: wrapper

            readonly property int barSpace: Config.bar.height + Config.bar.margin * 2
            readonly property bool fromTop: root.position.startsWith("top")

            implicitWidth: loader.item?.implicitWidth ?? 0
            implicitHeight: loader.item?.implicitHeight ?? 0
            width: implicitWidth
            height: implicitHeight
            focus: true

            x: {
                if (root.position === "topLeft" || root.position === "left")
                    return root.offset;
                if (root.position === "topRight" || root.position === "right")
                    return win.width - width - root.offset;
                return (win.width - width) / 2;
            }

            y: {
                if (root.position === "center")
                    return (win.height - height) / 2;
                if (fromTop)
                    return barSpace;
                return (win.height - height) / 2;
            }

            opacity: win.shouldShow ? 1 : 0
            scale: win.shouldShow ? 1 : 0.96
            transformOrigin: fromTop ? Item.Top : Item.Center

            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.anim.normal
                    easing.type: Appearance.anim.curve
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Appearance.anim.normal
                    easing.type: Appearance.anim.emphasized
                }
            }

            Keys.onEscapePressed: Visibilities[root.name] = false

            MouseArea {
                anchors.fill: parent
                // swallow clicks so the outside area does not close the panel
            }

            Loader {
                id: loader
                active: win.shown
                sourceComponent: root.content
                focus: true
            }
        }
    }
}
