import QtQuick
import qs.config
import qs.services

Rectangle {
    color: Colors.surfaceContainer
    radius: Appearance.rounding.normal
    antialiasing: true

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.fast
        }
    }
}
