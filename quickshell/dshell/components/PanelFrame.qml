import QtQuick
import qs.config
import qs.services

// Rounded panel surface with a thin outline. All pop out panels use it.
Rectangle {
    id: root

    property int padding: Appearance.spacing.large
    default property alias content: inner.data

    color: Colors.panel
    radius: Appearance.rounding.large
    border.width: 1
    border.color: Colors.alpha(Colors.outlineVariant, 0.5)
    antialiasing: true

    implicitWidth: inner.childrenRect.width + padding * 2
    implicitHeight: inner.childrenRect.height + padding * 2

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
