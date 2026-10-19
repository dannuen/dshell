pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property date now: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    // "2 min ago" style text for notification times
    function ago(ts: double): string {
        const diff = Math.max(0, (Date.now() - ts) / 1000);
        if (diff < 60)
            return "now";
        if (diff < 3600)
            return `${Math.floor(diff / 60)} min`;
        if (diff < 86400)
            return `${Math.floor(diff / 3600)} h`;
        return `${Math.floor(diff / 86400)} d`;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
