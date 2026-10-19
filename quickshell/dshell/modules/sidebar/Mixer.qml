pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pipewire
import qs.config
import qs.services
import qs.components

// Per app volume and the output device picker.
Column {
    id: root

    spacing: Appearance.spacing.small

    StyledText {
        visible: Audio.streams.length === 0
        text: "No apps playing audio"
        color: Colors.fgSurfaceVariant
        padding: Appearance.spacing.small
    }

    Repeater {
        model: Audio.streams

        Row {
            id: stream
            required property PwNode modelData
            readonly property string appName: modelData.properties["application.name"] ?? modelData.nickname ?? modelData.name

            width: root.width
            spacing: Appearance.spacing.small

            Column {
                width: parent.width - mute.width - parent.spacing
                spacing: Appearance.spacing.tiny
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    width: parent.width
                    text: stream.appName
                    font.pointSize: Appearance.fontSize.small
                    color: Colors.fgSurfaceVariant
                }

                StyledSlider {
                    width: parent.width
                    trackHeight: 20
                    value: stream.modelData.audio?.volume ?? 0
                    accent: stream.modelData.audio?.muted ? Colors.outline : Colors.primary
                    onMoved: v => {
                        if (stream.modelData.audio)
                            stream.modelData.audio.volume = v;
                    }
                }
            }

            IconButton {
                id: mute
                anchors.verticalCenter: parent.verticalCenter
                icon: stream.modelData.audio?.muted ? "volume_off" : "volume_up"
                onClicked: {
                    if (stream.modelData.audio)
                        stream.modelData.audio.muted = !stream.modelData.audio.muted;
                }
            }
        }
    }

    Separator {
        width: root.width
    }

    StyledText {
        text: "Output device"
        color: Colors.fgSurfaceVariant
        font.pointSize: Appearance.fontSize.small
    }

    Repeater {
        model: Audio.sinks

        StyledRect {
            id: sinkRow
            required property PwNode modelData
            readonly property bool current: Audio.sink === modelData

            width: root.width
            implicitHeight: 36
            radius: Appearance.rounding.small
            color: current ? Colors.secondaryContainer : "transparent"

            StateLayer {
                onClicked: Audio.setDefaultSink(sinkRow.modelData)
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: Appearance.spacing.normal
                anchors.rightMargin: Appearance.spacing.normal
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: sinkRow.current ? "radio_button_checked" : "radio_button_unchecked"
                    color: sinkRow.current ? Colors.primary : Colors.fgSurfaceVariant
                    font.pointSize: Appearance.fontSize.normal
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 30
                    text: sinkRow.modelData.description || sinkRow.modelData.name
                }
            }
        }
    }
}
