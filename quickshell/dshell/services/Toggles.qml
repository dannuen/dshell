pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

// Quick settings toggles: night light, caffeine, power profile.
Singleton {
    id: root

    property bool nightLight: false
    property bool caffeine: false
    property string powerProfile: "balanced"
    readonly property list<string> profiles: ["power-saver", "balanced", "performance"]

    readonly property string powerIcon: powerProfile === "performance" ? "speed" : (powerProfile === "power-saver" ? "energy_savings_leaf" : "balance")

    function toggleNightLight(): void {
        nightLight = !nightLight;
        const t = Config.sidebar.nightTemperature;
        Quickshell.execDetached(["sh", "-c", nightLight ? `hyprctl hyprsunset temperature ${t} || hyprsunset -t ${t} &` : "hyprctl hyprsunset identity"]);
    }

    function toggleCaffeine(): void {
        caffeine = !caffeine;
        if (caffeine)
            inhibit.running = true;
        else
            inhibit.running = false;
    }

    function cyclePowerProfile(): void {
        const i = (profiles.indexOf(powerProfile) + 1) % profiles.length;
        setPowerProfile(profiles[i]);
    }

    function setPowerProfile(p: string): void {
        powerProfile = p;
        Quickshell.execDetached(["powerprofilesctl", "set", p]);
    }

    Process {
        id: inhibit
        command: ["systemd-inhibit", "--what=idle", "--who=dshell", "--why=Caffeine", "sleep", "infinity"]
    }

    Process {
        id: ppRead
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim();
                if (v)
                    root.powerProfile = v;
            }
        }
    }
}
