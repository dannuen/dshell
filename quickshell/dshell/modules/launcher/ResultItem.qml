import QtQuick
import qs.config
import qs.services
import qs.components

// One row in the launcher results.
StyledRect {
    id: root

    property string icon: ""        // icon theme name
    property string symbol: ""      // material icon used when icon is empty
    property string emoji: ""       // plain text glyph shown instead of an icon
    property string title: ""
    property string subtitle: ""
    property bool selected: false

    signal clicked
    signal middleClicked

    implicitHeight: 52
    radius: Appearance.rounding.normal
    color: selected ? Colors.primaryContainer : "transparent"

    Row {
        anchors.fill: parent
        anchors.leftMargin: Appearance.spacing.normal
        anchors.rightMargin: Appearance.spacing.normal
        spacing: Appearance.spacing.normal

        Item {
            width: 36
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            AppIcon {
                anchors.centerIn: parent
                visible: root.emoji === "" && (root.icon !== "" || root.symbol === "")
                icon: root.icon
                fallback: root.symbol !== "" ? root.symbol : "apps"
                size: 32
            }

            MaterialIcon {
                anchors.centerIn: parent
                visible: root.emoji === "" && root.icon === "" && root.symbol !== ""
                text: root.symbol
                font.pointSize: Appearance.fontSize.iconLarge
                color: root.selected ? Colors.onPrimaryContainer : Colors.onSurfaceVariant
            }

            StyledText {
                anchors.centerIn: parent
                visible: root.emoji !== ""
                text: root.emoji
                font.pointSize: Appearance.fontSize.extraLarge
            }
        }

        Column {
            width: parent.width - 36 - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            StyledText {
                width: parent.width
                text: root.title
                color: root.selected ? Colors.onPrimaryContainer : Colors.onSurface
                font.pointSize: Appearance.fontSize.normal
            }

            StyledText {
                width: parent.width
                visible: root.subtitle !== ""
                text: root.subtitle
                color: root.selected ? Colors.onPrimaryContainer : Colors.onSurfaceVariant
                font.pointSize: Appearance.fontSize.small
                opacity: 0.8
            }
        }
    }

    StateLayer {
        color: root.selected ? Colors.onPrimaryContainer : Colors.onSurface
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                root.middleClicked();
            else
                root.clicked();
        }
    }
}
