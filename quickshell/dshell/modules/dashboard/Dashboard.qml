import QtQuick
import qs.config
import qs.services
import qs.components

// Dashboard, Super+D or click the clock.
PopupPanel {
    name: "dashboard"
    position: "top"

    onOpened: SystemStats.active = true
    onClosed: SystemStats.active = false

    content: PanelFrame {
        id: frame

        readonly property int innerWidth: Config.dashboard.width
        readonly property int leftWidth: Config.dashboard.showCalendar ? 300 : 0

        width: innerWidth + padding * 2
        implicitHeight: Math.max(cal.implicitHeight, right.implicitHeight) + padding * 2

        Calendar {
            id: cal
            visible: Config.dashboard.showCalendar
            width: frame.leftWidth
        }

        Column {
            id: right
            x: frame.leftWidth > 0 ? frame.leftWidth + Appearance.spacing.large : 0
            width: frame.innerWidth - x
            spacing: Appearance.spacing.normal

            MediaCard {
                visible: Config.dashboard.showMedia
                width: parent.width
            }

            WeatherCard {
                visible: Config.dashboard.showWeather
                width: parent.width
            }

            StatsCard {
                visible: Config.dashboard.showStats
                width: parent.width
            }
        }
    }
}
