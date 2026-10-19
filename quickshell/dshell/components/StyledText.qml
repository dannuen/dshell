import QtQuick
import qs.config
import qs.services

Text {
    color: Colors.fgSurface
    font.family: Appearance.font
    font.pointSize: Appearance.fontSize.normal
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.fast
        }
    }
}
