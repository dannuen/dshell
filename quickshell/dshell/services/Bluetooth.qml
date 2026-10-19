pragma Singleton

import Quickshell
import Quickshell.Bluetooth as QsBt
import QtQuick

Singleton {
    id: root

    readonly property QsBt.BluetoothAdapter adapter: QsBt.Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false
    readonly property var devices: adapter?.devices.values ?? []
    readonly property var connectedDevices: devices.filter(d => d.connected)
    readonly property var pairedDevices: devices.filter(d => d.paired || d.bonded)
    readonly property bool connected: connectedDevices.length > 0

    readonly property string icon: !enabled ? "bluetooth_disabled" : (connected ? "bluetooth_connected" : "bluetooth")
    readonly property string label: !enabled ? "Off" : (connected ? connectedDevices[0].name : "On")

    function toggle(): void {
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }

    function setDiscovering(on: bool): void {
        if (adapter)
            adapter.discovering = on;
    }

    function deviceIcon(d: QsBt.BluetoothDevice): string {
        const i = d?.icon ?? "";
        if (i.includes("headset") || i.includes("headphone"))
            return "headphones";
        if (i.includes("audio"))
            return "speaker";
        if (i.includes("phone"))
            return "smartphone";
        if (i.includes("mouse"))
            return "mouse";
        if (i.includes("keyboard"))
            return "keyboard";
        if (i.includes("computer"))
            return "computer";
        return "bluetooth";
    }
}
