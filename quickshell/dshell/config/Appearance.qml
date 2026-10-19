pragma Singleton

import Quickshell
import QtQuick

// Shared look values derived from Config so modules do not repeat them.
Singleton {
    id: root

    readonly property string font: Config.appearance.font
    // Fall back to any installed Material Symbols variant so icons never
    // render as plain text when the configured family is missing.
    readonly property string iconFont: {
        const want = Config.appearance.iconFont;
        const have = Qt.fontFamilies();
        if (have.indexOf(want) >= 0)
            return want;
        const alts = ["Material Symbols Rounded", "Material Symbols Outlined", "Material Symbols Sharp"];
        for (const f of alts) {
            if (have.indexOf(f) >= 0) {
                console.warn(`dshell: icon font "${want}" not installed, using "${f}"`);
                return f;
            }
        }
        console.warn(`dshell: icon font "${want}" not installed. Run scripts/fonts.sh`);
        return want;
    }
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
