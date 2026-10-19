pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components

// Month calendar, Monday first.
Column {
    id: root

    property int year: new Date().getFullYear()
    property int month: new Date().getMonth()

    readonly property date today: Time.now
    readonly property var days: {
        const first = new Date(year, month, 1);
        // Monday = 0
        const offset = (first.getDay() + 6) % 7;
        const start = new Date(year, month, 1 - offset);
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
            out.push({
                day: d.getDate(),
                current: d.getMonth() === month,
                today: d.getFullYear() === today.getFullYear() && d.getMonth() === today.getMonth() && d.getDate() === today.getDate()
            });
        }
        return out;
    }

    spacing: Appearance.spacing.small

    function prev(): void {
        if (month === 0) {
            month = 11;
            year -= 1;
        } else {
            month -= 1;
        }
    }

    function next(): void {
        if (month === 11) {
            month = 0;
            year += 1;
        } else {
            month += 1;
        }
    }

    Row {
        width: parent.width
        spacing: Appearance.spacing.small

        IconButton {
            icon: "chevron_left"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.prev()
        }

        StyledText {
            width: parent.width - 44 * 2 - parent.spacing * 2
            text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
            horizontalAlignment: Text.AlignHCenter
            font.weight: Font.DemiBold
            font.pointSize: Appearance.fontSize.large
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.year = root.today.getFullYear();
                    root.month = root.today.getMonth();
                }
            }
        }

        IconButton {
            icon: "chevron_right"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.next()
        }
    }

    Grid {
        id: grid
        width: parent.width
        columns: 7
        readonly property real cell: width / 7

        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

            StyledText {
                required property string modelData
                width: grid.cell
                height: 28
                text: modelData
                horizontalAlignment: Text.AlignHCenter
                color: Colors.fgSurfaceVariant
                font.pointSize: Appearance.fontSize.small
            }
        }

        Repeater {
            model: root.days

            Item {
                id: cell
                required property var modelData
                width: grid.cell
                height: 36

                Rectangle {
                    anchors.centerIn: parent
                    width: 32
                    height: 32
                    radius: Appearance.rounding.full
                    color: cell.modelData.today ? Colors.primary : "transparent"
                }

                StyledText {
                    anchors.centerIn: parent
                    text: cell.modelData.day
                    color: cell.modelData.today ? Colors.fgPrimary : (cell.modelData.current ? Colors.fgSurface : Colors.outline)
                    font.weight: cell.modelData.today ? Font.Bold : Font.Normal
                }
            }
        }
    }
}
