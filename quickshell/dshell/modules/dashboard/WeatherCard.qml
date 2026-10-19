pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components

StyledRect {
    id: root

    implicitHeight: content.implicitHeight + Appearance.spacing.normal * 2
    color: Colors.surfaceContainer

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: Appearance.spacing.normal
        spacing: Appearance.spacing.small

        Row {
            width: parent.width
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: Weather.icon
                font.pointSize: Appearance.fontSize.huge * 0.7
                color: Colors.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                width: parent.width - 60 - 44 - parent.spacing * 2
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    text: Weather.loaded ? Weather.temp : "..."
                    font.pointSize: Appearance.fontSize.extraLarge
                    font.weight: Font.DemiBold
                }

                StyledText {
                    width: parent.width
                    text: Weather.loaded ? `${Weather.description}, feels like ${Weather.feelsLike}` : "Loading weather"
                    color: Colors.fgSurfaceVariant
                    font.pointSize: Appearance.fontSize.small
                }

                StyledText {
                    width: parent.width
                    visible: Weather.loaded
                    text: `${Weather.city}  ·  humidity ${Weather.humidity}  ·  wind ${Weather.wind}`
                    color: Colors.fgSurfaceVariant
                    font.pointSize: Appearance.fontSize.small
                }
            }

            IconButton {
                icon: "refresh"
                tooltip: "Refresh"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: Weather.refresh()
            }
        }

        Row {
            visible: Weather.loaded
            width: parent.width

            Repeater {
                model: Weather.forecast

                Column {
                    required property var modelData
                    width: parent.width / 3
                    spacing: 2

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDate(new Date(modelData.date), "ddd")
                        color: Colors.fgSurfaceVariant
                        font.pointSize: Appearance.fontSize.small
                    }

                    MaterialIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.icon
                        color: Colors.fgSurfaceVariant
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: `${modelData.max} / ${modelData.min}`
                        font.pointSize: Appearance.fontSize.small
                    }
                }
            }
        }
    }
}
