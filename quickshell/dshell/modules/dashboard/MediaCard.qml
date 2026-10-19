import QtQuick
import Quickshell.Services.Mpris
import qs.config
import qs.services
import qs.components
import qs.utils

// MPRIS player card.
StyledRect {
    id: root

    readonly property MprisPlayer player: Players.active
    readonly property real progress: (player && player.lengthSupported && player.length > 0) ? player.position / player.length : 0

    implicitHeight: content.implicitHeight + Appearance.spacing.normal * 2
    color: Colors.surfaceContainer

    Timer {
        interval: 1000
        running: root.player?.isPlaying ?? false
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: Appearance.spacing.normal
        spacing: Appearance.spacing.small

        StyledText {
            visible: !root.player
            width: parent.width
            text: "Nothing playing"
            color: Colors.fgSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
            height: 60
        }

        Row {
            visible: root.player
            width: parent.width
            spacing: Appearance.spacing.normal

            StyledRect {
                width: 64
                height: 64
                radius: Appearance.rounding.small
                color: Colors.surfaceContainerHighest
                clip: true

                Image {
                    anchors.fill: parent
                    source: Players.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    visible: Players.artUrl === ""
                    text: "music_note"
                    color: Colors.fgSurfaceVariant
                }
            }

            Column {
                width: parent.width - 64 - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.spacing.tiny

                StyledText {
                    width: parent.width
                    text: Players.title || "Unknown title"
                    font.weight: Font.DemiBold
                }

                StyledText {
                    width: parent.width
                    text: Players.artist
                    color: Colors.fgSurfaceVariant
                    font.pointSize: Appearance.fontSize.small
                }

                Row {
                    spacing: Appearance.spacing.small

                    IconButton {
                        icon: "skip_previous"
                        disabled: !(root.player?.canGoPrevious ?? false)
                        onClicked: Players.previous()
                    }

                    IconButton {
                        icon: Players.playing ? "pause" : "play_arrow"
                        fill: true
                        active: true
                        onClicked: Players.playPause()
                    }

                    IconButton {
                        icon: "skip_next"
                        disabled: !(root.player?.canGoNext ?? false)
                        onClicked: Players.next()
                    }
                }
            }
        }

        Row {
            visible: root.player && root.player.lengthSupported
            width: parent.width
            spacing: Appearance.spacing.small

            StyledText {
                text: Format.duration(root.player?.position ?? 0)
                color: Colors.fgSurfaceVariant
                font.pointSize: Appearance.fontSize.small
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledSlider {
                width: parent.width - 80 - parent.spacing * 2
                trackHeight: 8
                value: root.progress
                anchors.verticalCenter: parent.verticalCenter
                onMoved: v => {
                    if (root.player?.canSeek)
                        root.player.position = v * root.player.length;
                }
            }

            StyledText {
                text: Format.duration(root.player?.length ?? 0)
                color: Colors.fgSurfaceVariant
                font.pointSize: Appearance.fontSize.small
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
