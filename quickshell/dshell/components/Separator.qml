import QtQuick
import qs.config
import qs.services

Rectangle {
    property bool vertical: false
    implicitWidth: vertical ? 1 : parent?.width ?? 1
    implicitHeight: vertical ? parent?.height ?? 1 : 1
    color: Colors.alpha(Colors.outlineVariant, 0.6)
}
