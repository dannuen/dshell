import QtQuick
import qs.config
import qs.services
import qs.components

// EN / VI indicator. Click to switch the fcitx5 input method.
StyledRect {
    id: root

    implicitWidth: label.implicitWidth + Appearance.spacing.normal * 2 + 4
    implicitHeight: Config.bar.height - Appearance.spacing.normal
    radius: Appearance.rounding.full
    color: Fcitx.vietnamese ? Colors.tertiaryContainer : Colors.surfaceContainerHigh

    StyledText {
        id: label
        anchors.centerIn: parent
        text: Fcitx.label
        font.bold: true
        font.pointSize: Appearance.fontSize.small
        color: Fcitx.vietnamese ? Colors.onTertiaryContainer : Colors.onSurface
    }

    StateLayer {
        onClicked: Fcitx.toggle()
    }

    Tooltip {
        text: Fcitx.vietnamese ? "Vietnamese (Telex)" : "English"
        visible: false
    }
}
