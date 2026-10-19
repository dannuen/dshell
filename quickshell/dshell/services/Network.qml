pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property WifiDevice wifi: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property WiredDevice wired: devices.find(d => d.type === DeviceType.Wired) ?? null

    property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wiredConnected: wired?.connected ?? false
    readonly property bool wifiConnected: wifi?.connected ?? false
    readonly property bool connected: wiredConnected || wifiConnected

    readonly property var networks: wifi?.networks.values ?? []
    readonly property WifiNetwork active: networks.find(n => n.connected) ?? null
    readonly property string ssid: active?.name ?? ""
    readonly property real strength: active?.signalStrength ?? 0

    readonly property string icon: {
        if (wiredConnected)
            return "lan";
        if (!wifiEnabled)
            return "wifi_off";
        if (!wifiConnected)
            return "signal_wifi_0_bar";
        if (strength > 0.8)
            return "signal_wifi_4_bar";
        if (strength > 0.55)
            return "network_wifi_3_bar";
        if (strength > 0.3)
            return "network_wifi_2_bar";
        return "network_wifi_1_bar";
    }

    readonly property string label: wiredConnected ? "Wired" : (wifiConnected ? ssid : (wifiEnabled ? "Not connected" : "Wi-Fi off"))

    function toggleWifi(): void {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function scan(enabled: bool): void {
        if (wifi)
            wifi.scannerEnabled = enabled;
    }

    function connect(network: WifiNetwork, psk: string): void {
        if (!network)
            return;
        if (psk && psk.length > 0)
            network.connectWithPsk(psk);
        else
            network.connect();
    }

    function strengthIcon(s: real): string {
        if (s > 0.8)
            return "signal_wifi_4_bar";
        if (s > 0.55)
            return "network_wifi_3_bar";
        if (s > 0.3)
            return "network_wifi_2_bar";
        return "network_wifi_1_bar";
    }
}
