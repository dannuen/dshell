import QtQuick
import qs.config
import qs.services

// Text input inside a rounded field.
StyledRect {
    id: root

    property alias text: input.text
    property alias placeholder: placeholderItem.text
    property alias input: input
    property string icon: ""
    property bool password: false

    signal accepted
    signal escapePressed
    signal upPressed
    signal downPressed
    signal tabPressed

    implicitHeight: 48
    radius: Appearance.rounding.full
    color: Colors.surfaceContainerHigh

    function focusInput(): void {
        input.forceActiveFocus();
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Appearance.spacing.large
        anchors.rightMargin: Appearance.spacing.large
        spacing: Appearance.spacing.normal

        MaterialIcon {
            visible: root.icon !== ""
            text: root.icon
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.fgSurfaceVariant
        }

        Item {
            width: parent.width - (root.icon !== "" ? 36 : 0)
            height: parent.height

            TextInput {
                id: input
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                color: Colors.fgSurface
                font.family: Appearance.font
                font.pointSize: Appearance.fontSize.large
                selectionColor: Colors.primary
                selectedTextColor: Colors.fgPrimary
                clip: true
                echoMode: root.password ? TextInput.Password : TextInput.Normal
                inputMethodHints: root.password ? Qt.ImhHiddenText | Qt.ImhNoPredictiveText : Qt.ImhNone

                onAccepted: root.accepted()
                Keys.onEscapePressed: root.escapePressed()
                Keys.onUpPressed: root.upPressed()
                Keys.onDownPressed: root.downPressed()
                Keys.onTabPressed: root.tabPressed()
            }

            StyledText {
                id: placeholderItem
                anchors.fill: parent
                visible: input.text.length === 0
                color: Colors.fgSurfaceVariant
                font.pointSize: Appearance.fontSize.large
            }
        }
    }
}
