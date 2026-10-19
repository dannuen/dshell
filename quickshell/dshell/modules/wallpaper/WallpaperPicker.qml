pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components

// Wallpaper grid. Picking one runs matugen and recolors everything. Super+W.
PopupPanel {
    id: root

    name: "wallpaper"
    position: "top"

    content: Component {
        PanelFrame {
            id: frame

            readonly property int thumbW: 160
            readonly property int thumbH: 90
            readonly property int cols: 4
            readonly property int gap: Appearance.spacing.normal

            Component.onCompleted: Wallpapers.refresh()

            Column {
                spacing: frame.gap

                Row {
                    spacing: Appearance.spacing.normal

                    StyledText {
                        text: "Wallpapers"
                        font.pointSize: Appearance.fontSize.large
                        anchors.verticalCenter: parent.verticalCenter
                        width: frame.cols * frame.thumbW + (frame.cols - 1) * frame.gap - 3 * 44
                    }

                    IconButton {
                        icon: "shuffle"
                        tooltip: "Random"
                        onClicked: Wallpapers.random()
                    }

                    IconButton {
                        icon: Colors.light ? "dark_mode" : "light_mode"
                        tooltip: Colors.light ? "Switch to dark" : "Switch to light"
                        onClicked: Wallpapers.toggleMode()
                    }

                    IconButton {
                        icon: "refresh"
                        tooltip: "Rescan folder"
                        onClicked: Wallpapers.refresh()
                    }
                }

                GridView {
                    id: grid
                    width: frame.cols * (frame.thumbW + frame.gap)
                    height: Math.min(500, Math.ceil(Math.max(1, count) / frame.cols) * (frame.thumbH + frame.gap))
                    clip: true
                    cellWidth: frame.thumbW + frame.gap
                    cellHeight: frame.thumbH + frame.gap
                    model: Wallpapers.list
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Item {
                        id: cell
                        required property string modelData
                        readonly property bool current: modelData === Wallpapers.current

                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: frame.gap / 2 - 3
                            radius: Appearance.rounding.normal + 3
                            color: "transparent"
                            border.width: 3
                            border.color: cell.current ? Colors.primary : "transparent"
                        }

                        Rectangle {
                            id: thumbFrame
                            anchors.fill: parent
                            anchors.margins: frame.gap / 2
                            radius: Appearance.rounding.normal
                            color: Colors.surfaceContainerHigh
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: "file://" + cell.modelData
                                sourceSize.width: frame.thumbW * 2
                                sourceSize.height: frame.thumbH * 2
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                smooth: true
                            }

                            StateLayer {
                                radius: thumbFrame.radius
                                onClicked: {
                                    Wallpapers.set(cell.modelData);
                                    Visibilities.wallpaper = false;
                                }
                            }
                        }
                    }
                }

                StyledText {
                    visible: Wallpapers.list.length === 0
                    text: `No images found in ${Config.wallpaper.dir}`
                    color: Colors.onSurfaceVariant
                }
            }
        }
    }
}
