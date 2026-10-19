import QtQuick
import qs.config
import qs.services

// Material Symbols Rounded icon. `text` is the icon name, e.g. "wifi".
Text {
    property bool fill: false
    property int grade: 0

    color: Colors.onSurface
    font.family: Appearance.iconFont
    font.pointSize: Appearance.fontSize.icon
    font.variableAxes: ({
            FILL: fill ? 1 : 0,
            GRAD: grade,
            opsz: 24,
            wght: 400
        })
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.fast
        }
    }
}
