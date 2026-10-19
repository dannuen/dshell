pragma Singleton

import Quickshell
import QtQuick

// Shared look values derived from Config so modules do not repeat them.
Singleton {
    id: root

    readonly property string font: Config.appearance.font
    readonly property string iconFont: Config.appearance.iconFont
    readonly property string monoFont: Config.appearance.font

    readonly property QtObject fontSize: QtObject {
        readonly property int small: Config.appearance.fontSize - 2
        readonly property int normal: Config.appearance.fontSize
        readonly property int large: Config.appearance.fontSize + 4
        readonly property int extraLarge: Config.appearance.fontSize + 12
        readonly property int huge: Config.appearance.fontSize * 4
        readonly property int icon: Config.appearance.fontSize + 6
        readonly property int iconLarge: Config.appearance.fontSize + 14
    }

    readonly property QtObject rounding: QtObject {
        readonly property int small: Math.max(4, Config.appearance.rounding / 2)
        readonly property int normal: Config.appearance.rounding
        readonly property int large: Config.appearance.rounding * 1.5
        readonly property int full: 1000
    }

    readonly property QtObject spacing: QtObject {
        readonly property int tiny: 2
        readonly property int small: Config.appearance.padding / 2
        readonly property int normal: Config.appearance.padding
        readonly property int large: Config.appearance.padding * 2
        readonly property int huge: Config.appearance.padding * 3
    }

    readonly property QtObject anim: QtObject {
        readonly property int fast: 120 * Config.appearance.animationSpeed
        readonly property int normal: 220 * Config.appearance.animationSpeed
        readonly property int slow: 400 * Config.appearance.animationSpeed
        readonly property var curve: Easing.OutCubic
        readonly property var emphasized: Easing.OutQuint
    }

    readonly property real panelOpacity: Config.appearance.panelOpacity
}
