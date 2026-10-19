pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool available: device?.isLaptopBattery ?? false
    readonly property real percentage: device?.percentage ?? 0
    readonly property bool charging: device?.state === UPowerDeviceState.Charging || device?.state === UPowerDeviceState.FullyCharged
    readonly property bool onBattery: UPower.onBattery
    readonly property bool low: !charging && percentage <= 0.2
    readonly property bool critical: !charging && percentage <= 0.08

    readonly property string icon: {
        if (!available)
            return "battery_unknown";
        const p = Math.round(percentage * 100);
        if (charging)
            return p >= 100 ? "battery_charging_full" : "battery_charging_full";
        if (p >= 95)
            return "battery_full";
        if (p >= 80)
            return "battery_6_bar";
        if (p >= 65)
            return "battery_5_bar";
        if (p >= 50)
            return "battery_4_bar";
        if (p >= 35)
            return "battery_3_bar";
        if (p >= 20)
            return "battery_2_bar";
        if (p >= 10)
            return "battery_1_bar";
        return "battery_alert";
    }

    readonly property string timeText: {
        if (!available)
            return "";
        const secs = charging ? device.timeToFull : device.timeToEmpty;
        if (!secs || secs <= 0)
            return charging ? "Charging" : "";
        const h = Math.floor(secs / 3600);
        const m = Math.floor((secs % 3600) / 60);
        const t = h > 0 ? `${h} h ${m} min` : `${m} min`;
        return charging ? `${t} until full` : `${t} left`;
    }
}
