pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config
import qs.services
import qs.components

// Session lock with PAM password. Super+L, or hypridle after a timeout.
Scope {
    id: root

    property string status: ""
    property bool failed: false

    Connections {
        target: Visibilities

        function onLockRequested(): void {
            Visibilities.closeAll();
            Visibilities.locked = true;
        }

        function onLockedChanged(): void {
            const cmd = Visibilities.locked ? Config.hooks.locked : Config.hooks.unlocked;
            if (cmd && cmd.length > 0)
                Quickshell.execDetached(["sh", "-c", cmd]);
            if (!Visibilities.locked) {
                root.status = "";
                root.failed = false;
            }
        }
    }

    WlSessionLock {
        id: lock

        locked: Visibilities.locked

        surface: Component {
            WlSessionLockSurface {
                id: surface

                color: Colors.background

                Image {
                    id: wall
                    anchors.fill: parent
                    source: Config.wallpaper.current ? "file://" + Config.wallpaper.current : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: !Config.lock.blur || !blurFx.visible
                }

                MultiEffect {
                    id: blurFx
                    anchors.fill: wall
                    source: wall
                    visible: Config.lock.blur && wall.status === Image.Ready
                    blurEnabled: true
                    blur: 1.0
                    blurMax: 64
                    autoPaddingEnabled: false
                }

                Rectangle {
                    anchors.fill: parent
                    color: Colors.alpha(Colors.background, 0.45)
                }

                Column {
                    id: center
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.large
                    width: 360

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Time.format(Config.lock.clockFormat)
                        font.pointSize: Appearance.fontSize.huge
                        font.weight: Font.Medium
                        color: Colors.fgBackground
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Time.format(Config.lock.dateFormat)
                        font.pointSize: Appearance.fontSize.large
                        color: Colors.fgSurfaceVariant
                    }

                    Item {
                        width: 1
                        height: Appearance.spacing.huge
                    }

                    PanelFrame {
                        id: box
                        width: parent.width
                        padding: Appearance.spacing.normal
                        property real shakeX: 0
                        transform: Translate { x: box.shakeX }

                        SequentialAnimation {
                            id: shake
                            NumberAnimation { target: box; property: "shakeX"; to: -12; duration: 50 }
                            NumberAnimation { target: box; property: "shakeX"; to: 12; duration: 50 }
                            NumberAnimation { target: box; property: "shakeX"; to: -8; duration: 50 }
                            NumberAnimation { target: box; property: "shakeX"; to: 8; duration: 50 }
                            NumberAnimation { target: box; property: "shakeX"; to: 0; duration: 50 }
                        }

                        Column {
                            width: box.width - box.padding * 2
                            spacing: Appearance.spacing.normal

                            StyledTextField {
                                id: passwordField
                                width: parent.width
                                icon: pam.active ? "hourglass_top" : "lock"
                                password: true
                                placeholder: "Password"
                                color: root.failed ? Colors.errorContainer : Colors.surfaceContainerHigh
                                input.enabled: !pam.active

                                onAccepted: {
                                    if (pam.active || text.length === 0)
                                        return;
                                    root.failed = false;
                                    root.status = "Checking...";
                                    pam.start();
                                }

                                Component.onCompleted: focusInput()
                            }

                            StyledText {
                                width: parent.width
                                visible: root.status !== ""
                                text: root.status
                                color: root.failed ? Colors.error : Colors.fgSurfaceVariant
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: Appearance.fontSize.small
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Appearance.spacing.large
                        visible: Battery.available

                        MaterialIcon {
                            text: Battery.icon
                            color: Colors.fgSurfaceVariant
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: `${Math.round(Battery.percentage * 100)}%`
                            color: Colors.fgSurfaceVariant
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                PamContext {
                    id: pam
                    config: "login"
                    user: Quickshell.env("USER")

                    onResponseRequiredChanged: {
                        if (responseRequired)
                            respond(passwordField.text);
                    }

                    onCompleted: result => {
                        if (result === PamResult.Success) {
                            root.status = "";
                            passwordField.text = "";
                            Visibilities.locked = false;
                        } else {
                            root.failed = true;
                            root.status = result === PamResult.Error ? "Authentication error" : "Wrong password";
                            passwordField.text = "";
                            shake.restart();
                            passwordField.focusInput();
                        }
                    }
                }

                onVisibleChanged: if (visible)
                    passwordField.focusInput()
            }
        }
    }
}
