pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components

// One setting row. field = {key, label, type, choices?, min?, max?, step?}
Row {
    id: root

    required property string section
    required property var field

    readonly property var value: Config[section][field.key]

    width: parent.width
    height: Math.max(40, editor.height)
    spacing: Appearance.spacing.normal

    function apply(v: var): void {
        Config[section][field.key] = v;
        Config.save();
        if (section === "theme" && Config.wallpaper.current !== "")
            Wallpapers.set(Config.wallpaper.current);
    }

    StyledText {
        width: parent.width - editor.width - parent.spacing
        anchors.verticalCenter: parent.verticalCenter
        text: root.field.label
        wrapMode: Text.Wrap
    }

    Item {
        id: editor
        anchors.verticalCenter: parent.verticalCenter
        width: {
            if (root.field.type === "bool")
                return 48;
            if (root.field.type === "choice")
                return choiceRow.implicitWidth;
            if (root.field.type === "string")
                return 260;
            return numRow.implicitWidth;
        }
        height: {
            if (root.field.type === "bool")
                return 28;
            if (root.field.type === "choice")
                return choiceRow.implicitHeight;
            if (root.field.type === "string")
                return 40;
            return 36;
        }

        StyledSwitch {
            visible: root.field.type === "bool"
            checked: root.value === true
            onToggled: c => root.apply(c)
        }

        StyledTextField {
            visible: root.field.type === "string"
            width: 260
            implicitHeight: 40
            text: visible ? String(root.value ?? "") : ""
            input.font.pointSize: Appearance.fontSize.normal
            onAccepted: root.apply(text)
            input.onActiveFocusChanged: if (!input.activeFocus && text !== String(root.value ?? ""))
                root.apply(text)
        }

        Row {
            id: numRow
            visible: root.field.type === "int" || root.field.type === "real"
            spacing: Appearance.spacing.tiny

            readonly property real step: root.field.step ?? (root.field.type === "int" ? 1 : 0.1)
            readonly property real min: root.field.min ?? 0
            readonly property real max: root.field.max ?? 100000

            function bump(dir: int): void {
                let v = Number(root.value) + dir * step;
                v = Math.max(min, Math.min(max, v));
                root.apply(root.field.type === "int" ? Math.round(v) : Math.round(v * 100) / 100);
            }

            IconButton {
                icon: "remove"
                iconSize: Appearance.fontSize.normal
                anchors.verticalCenter: parent.verticalCenter
                onClicked: numRow.bump(-1)
            }

            StyledRect {
                width: 64
                height: 32
                radius: Appearance.rounding.small
                color: Colors.surfaceContainerHigh
                anchors.verticalCenter: parent.verticalCenter

                TextInput {
                    anchors.fill: parent
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter
                    color: Colors.onSurface
                    font.family: Appearance.font
                    font.pointSize: Appearance.fontSize.normal
                    text: numRow.visible ? String(root.value ?? "") : ""
                    validator: DoubleValidator {}
                    onEditingFinished: {
                        const v = Number(text);
                        if (!isNaN(v))
                            root.apply(root.field.type === "int" ? Math.round(v) : v);
                    }
                }
            }

            IconButton {
                icon: "add"
                iconSize: Appearance.fontSize.normal
                anchors.verticalCenter: parent.verticalCenter
                onClicked: numRow.bump(1)
            }
        }

        Flow {
            id: choiceRow
            visible: root.field.type === "choice"
            width: 320
            spacing: Appearance.spacing.tiny
            layoutDirection: Qt.RightToLeft

            Repeater {
                model: root.field.choices ?? []

                TextButton {
                    required property string modelData
                    text: modelData.replace("scheme-", "")
                    implicitHeight: 30
                    active: root.value === modelData
                    onClicked: root.apply(modelData)
                }
            }
        }
    }
}
